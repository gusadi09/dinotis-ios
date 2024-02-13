//
//  OtpVerificationViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation
import Combine
import SwiftUI
import DinotisDesignSystem
import DinotisData

final class OtpVerificationViewModel: ObservableObject {
    
    private let otpForgetPasswordUseCase: OTPForgotPasswordVerificationUseCase
    private let otpVerificationUseCase: OTPVerificationUseCase
    private let otpRegistrationUseCase: OTPRegistrationVerificationUseCase
    private let resendOtpUseCase: ResendOTPUseCase
    
    private let getUserUseCase: GetUserUseCase
    private let otpType: OTPType
    
    private var cancellables = Set<AnyCancellable>()
    
    @ObservedObject var stateObservable = StateObservable.shared
    
    @Published var route: PrimaryRouting?
    @Published var data: Users?
    @Published var otpForgetData: ForgetPasswordOTPResponse?
	@Published var selectedChannel: DeliveryOTPVia = .whatsapp
	@Published var isShowSelectChannel = false
    
    @Published var timeRemaining = 60
    @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Published var isActive = false
    @Published var timesUp = false
    
    @Published var onEdit = false
    
    @Published var otpNumber: String = ""
    
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var error: String?
    @Published var success: Bool = false
    
    @Published var otpError: String? = nil
    
    @Published var phoneNumber: String
    
    var onBackToRoot: () -> Void
    var backToLogin: () -> Void
    var backToPhoneSet: () -> Void
    
    init(
        phoneNumber: String,
        otpType: OTPType,
        onBackToRoot: @escaping (() -> Void),
        backToLogin: @escaping (() -> Void),
        backToPhoneSet: @escaping (() -> Void),
        otpForgetPasswordUseCase: OTPForgotPasswordVerificationUseCase = OTPForgotPasswordVerificationDefaultUseCase(),
        otpVerificationUseCase: OTPVerificationUseCase = OTPVerificationDefaultUseCase(),
        otpRegistrationUseCase: OTPRegistrationVerificationUseCase = OTPRegistrationVerificationDefaultUseCase(),
        resendOtpUseCase: ResendOTPUseCase = ResendOTPDefaultUseCase(),
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase()
    ) {
        self.phoneNumber = phoneNumber
        self.onBackToRoot = onBackToRoot
        self.otpForgetPasswordUseCase = otpForgetPasswordUseCase
        self.otpVerificationUseCase = otpVerificationUseCase
        self.otpRegistrationUseCase = otpRegistrationUseCase
        self.resendOtpUseCase = resendOtpUseCase
        self.getUserUseCase = getUserUseCase
        self.otpType = otpType
        self.backToLogin = backToLogin
        self.backToPhoneSet = backToPhoneSet
    }
    
    func registerTitleText() -> String {
        return (stateObservable.userType == 2) ? LocalizableText.titleRegisterCreator : LocalizableText.titleRegisterAudience
    }
    
    func timeRemainingText() -> String {
        return isActive ? LocalizableText.linkResendOTPActive : LocalizableText.linkResendOTP(with: timeRemaining)
    }
    
    func openWhatsApp() {
        if let waurl = URL(string: "https://wa.me/6281318506068") {
            if UIApplication.shared.canOpenURL(waurl) {
                UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
            }
        }
    }
    
    func onReceiveTimer() {
        if self.timeRemaining > 0 {
            self.timeRemaining -= 1
        } else {
            self.isActive = true
        }
    }
    
    func receiveTimerBackground() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.onReceiveTimer()
        }
    }
    
    func onEditingUnderlineColor() -> Color {
        self.onEdit ? .DinotisDefault.primary : .gray
    }
    
    func validateOTP() async {
        if otpNumber.count == 6 {
            
            let body = OTPVerificationRequest(phone: phoneNumber, otp: otpNumber)
            
            await otpVerification(body: body)
        }
    }
    
    func onStartFetch() {
        DispatchQueue.main.async {[weak self] in
            self?.isLoading = true
            self?.isError = false
            self?.error = nil
            self?.success = false
            self?.otpError = nil
        }
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false

            if let error = error as? ErrorResponse {
                
                if error.errorCode == "OTP_NOT_MATCH" {
                    self?.otpError = LocalizableText.alertSendOTPInvalid
                } else {
                    self?.otpError = error.message.orEmpty()
                }
                self?.otpNumber = ""
                
                self?.error = error.message.orEmpty()
                self?.isError = true
                
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }

        }
    }
    
    func otpVerification(body: OTPVerificationRequest) async {
        onStartFetch()
        
        switch otpType {
        case .register:
            
            let result = await otpRegistrationUseCase.execute(with: body)
            
            switch result {
            case .success(let success):
                DispatchQueue.main.async { [weak self] in
                    self?.success = true
                    self?.isLoading = false
                    self?.stateObservable.isVerified = "VerifiedNoName"
                    self?.stateObservable.accessToken = success.accessToken.orEmpty()
                    self?.stateObservable.refreshToken = success.refreshToken.orEmpty()
                    self?.routingPage(data: nil, otpForget: nil)
                }
            case .failure(let failure):
                handleDefaultError(error: failure)
            }
    
        case .forgetPassword:
            
            let result = await otpForgetPasswordUseCase.execute(with: body)
            
            switch result {
            case .success(let success):
                DispatchQueue.main.async { [weak self] in
                    self?.otpForgetData = success
                    self?.routingPage(data: nil, otpForget: success)
                }
            case .failure(let failure):
                handleDefaultError(error: failure)
            }
        case .login:
            
            let result = await otpVerificationUseCase.execute(with: body)
            
            switch result {
            case .success(let success):
                await self.getUsers()
                DispatchQueue.main.async { [weak self] in
                    self?.success = true
                    self?.isLoading = false
                    self?.stateObservable.accessToken = success.accessToken.orEmpty()
                    self?.stateObservable.refreshToken = success.refreshToken.orEmpty()
                }
            case .failure(let failure):
                handleDefaultError(error: failure)
            }
            
        }
        
    }
    
    func routingPage(data: UserResponse?, otpForget: ForgetPasswordOTPResponse?) {
		DispatchQueue.main.async { [weak self] in
			switch self?.otpType {
			case .register:
				let viewModel = BiodataViewModel()
				self?.route = .biodataUser(viewModel: viewModel)
			case .forgetPassword:
				let viewModel = ResetPasswordViewModel(
					phone: (self?.phoneNumber).orEmpty(),
					token: (otpForget?.token).orEmpty(),
                    backToRoot: self?.onBackToRoot ?? {},
                    backToLogin: self?.backToLogin ?? {},
                    backToPhoneSet: self?.backToPhoneSet ?? {}
                )
                self?.route = .resetPassword(viewModel: viewModel)
            case .login:
                if (data?.isPasswordFilled ?? false) || (!(data?.isPasswordFilled ?? false) && (data?.name).orEmpty().isEmpty) {
                    if !(data?.name).orEmpty().isEmpty {
                        
//                        if self?.stateObservable.userType == 3 {
                            self?.stateObservable.isVerified = "Verified"
							let vm = TabViewContainerViewModel(
                                isFromUserType: true, 
                                talentHomeVM: TalentHomeViewModel(isFromUserType: true),
                                userHomeVM: UserHomeViewModel(),
								profileVM: ProfileViewModel(backToHome: {}),
								searchVM: SearchTalentViewModel(backToHome: {}),
                                scheduleVM: ScheduleListViewModel(backToHome: {}, currentUserId: (data?.id).orEmpty())
							)

							DispatchQueue.main.async { [weak self] in
								self?.route = .tabContainer(viewModel: vm)
							}
                            
//                        } else if self?.stateObservable.userType == 2 {
//                            
//                            if data?.username != nil {
//                                self?.stateObservable.isVerified = "Verified"
//                                let viewModel = TalentHomeViewModel(isFromUserType: true)
//                                self?.route = .homeTalent(viewModel: viewModel)
//                                
//                            } else {
//                                self?.stateObservable.isVerified = VerifiedCondition.verifiedNoName
//                                let viewModel = BiodataViewModel()
//                                self?.route = .biodataTalent(viewModel: viewModel)
//                                
//                            }
//                            
//                        }
                        
                    } else {
                        self?.stateObservable.isVerified = VerifiedCondition.verifiedNoName
                        
                        if self?.stateObservable.userType == 3 {
                            let viewModel = BiodataViewModel()
                            self?.route = .biodataUser(viewModel: viewModel)
                            
                        } else if self?.stateObservable.userType == 2 {
                            let viewModel = BiodataViewModel()
                            self?.route = .biodataTalent(viewModel: viewModel)
                            
                        }
                        
                    }
                }
            case .none:
                break
            }
        }
    }
    
    func getUsers() async {
        onStartFetch()
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.routingPage(data: success, otpForget: nil)
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func onResendOTP() {
        Task {
            await resendOtp()
        }
    }
    
    func resendOtp() async {
        onStartFetch()
        
        let phone = OTPRequest(phone: phoneNumber, channel: selectedChannel.name)
        
        let result = await resendOtpUseCase.execute(with: phone)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.otpNumber = ""
                self?.timeRemaining = 60
                self?.isActive = false
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
}
