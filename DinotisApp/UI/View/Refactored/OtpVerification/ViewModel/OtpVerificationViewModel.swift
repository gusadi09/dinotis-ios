//
//  OtpVerificationViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation
import Combine
import SwiftUI

final class OtpVerificationViewModel: ObservableObject {
    
    private let repository: AuthenticationRepository
    
    private let userRepository: UsersRepository
    private let otpType: OTPType
    
    private var cancellables = Set<AnyCancellable>()
    
    @ObservedObject var stateObservable = StateObservable.shared
    
    @Published var route: PrimaryRouting?
    @Published var data: Users?
    @Published var otpForgetData: ForgetPasswordOtpResponse?
	@Published var selectedChannel: DeliveryOTPVia = .whatsapp
	@Published var isShowSelectChannel = false
    
    @Published var timeRemaining = 60
    @Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Published var isActive = false
    @Published var timesUp = false
    
    @Published var onEdit = false
    
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var error: HMError?
    @Published var success: Bool = false
    
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
        repository: AuthenticationRepository = AuthenticationDefaultRepository(),
        userRepository: UsersRepository = UsersDefaultRepository()
    ) {
        self.phoneNumber = phoneNumber
        self.onBackToRoot = onBackToRoot
        self.repository = repository
        self.userRepository = userRepository
        self.otpType = otpType
        self.backToLogin = backToLogin
        self.backToPhoneSet = backToPhoneSet
    }
    
    func onReceiveTimer() {
        if self.timeRemaining > 0 {
            self.timeRemaining -= 1
        } else {
            self.isActive = true
        }
    }
    
    func onEditingUnderlineColor() -> Color {
        self.onEdit ? .primaryViolet : .gray
    }
    
    func validateOTP(by otp: String) {
        if otp.count == 6 {
            
            let body = VerifyBody(phone: phoneNumber, otp: otp)
            
            otpVerification(body: body)
        }
    }
    
    func onStartFetch() {
        DispatchQueue.main.async {[weak self] in
            self?.isLoading = true
            self?.isError = false
            self?.error = nil
            self?.success = false
        }
    }
    
    func otpVerification(body: VerifyBody) {
        onStartFetch()
        
        switch otpType {
        case .register:
            repository
                .otpRegisterVerification(params: body)
                .sink { result in
                    switch result {
                    case .finished:
                        DispatchQueue.main.async { [weak self] in
                            self?.success = true
                            self?.isLoading = false
                        }
                        
                    case .failure(let error):
                        DispatchQueue.main.async {[weak self] in
                            self?.isError = true
                            self?.isLoading = false
                            self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
                        }
                    }
                } receiveValue: { value in
                    self.stateObservable.isVerified = "Verified"
                    self.stateObservable.accessToken = value.accessToken
                    self.stateObservable.refreshToken = value.refreshToken
                    self.routingPage(data: nil, otpForget: nil)
                }
                .store(in: &cancellables)
        case .forgetPassword:
            repository
                .otpForgetPasswordVerification(params: body)
                .sink { result in
                    switch result {
                    case .finished:
                        DispatchQueue.main.async { [weak self] in
                            self?.success = true
                            self?.isLoading = false
                        }
                        
                    case .failure(let error):
                        DispatchQueue.main.async {[weak self] in
                            self?.isError = true
                            self?.isLoading = false
                            self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
                        }
                    }
                } receiveValue: { value in
                    self.otpForgetData = value
                    self.routingPage(data: nil, otpForget: value)
                }
                .store(in: &cancellables)
        case .login:
            repository
                .otpVerification(params: body)
                .sink { result in
                    switch result {
                    case .finished:
                        DispatchQueue.main.async { [weak self] in
                            self?.success = true
                            self?.isLoading = false
                        }
                        
                    case .failure(let error):
                        DispatchQueue.main.async {[weak self] in
                            self?.isError = true
                            self?.isLoading = false
                            self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
                        }
                    }
                } receiveValue: { value in
                    self.stateObservable.accessToken = value.accessToken
                    self.stateObservable.refreshToken = value.refreshToken
                    self.getUsers()
                }
                .store(in: &cancellables)
        }
        
    }
    
    func routingPage(data: Users?, otpForget: ForgetPasswordOtpResponse?) {
        DispatchQueue.main.async { [weak self] in
            switch self?.otpType {
            case .register:
                if self?.stateObservable.userType == 3 {
                    let viewModel = BiodataViewModel(backToRoot: self?.onBackToRoot ?? {})
                    self?.route = .biodataUser(viewModel: viewModel)
                    
                } else if self?.stateObservable.userType == 2 {
                    let viewModel = BiodataViewModel(backToRoot: self?.onBackToRoot ?? {})
                    self?.route = .biodataTalent(viewModel: viewModel)
                    
                }
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
                        
                        if self?.stateObservable.userType == 3 {
                            self?.stateObservable.isVerified = "Verified"
                            let viewModel = UserHomeViewModel(backToRoot: self?.onBackToRoot ?? {})
                            self?.route = .homeUser(viewModel: viewModel)
                            
                        } else if self?.stateObservable.userType == 2 {
                            
                            if data?.username != nil {
                                self?.stateObservable.isVerified = "Verified"
                                let viewModel = TalentHomeViewModel(backToRoot: self?.onBackToRoot ?? {})
                                self?.route = .homeTalent(viewModel: viewModel)
                                
                            } else {
                                self?.stateObservable.isVerified = VerifiedCondition.verifiedNoName
                                let viewModel = BiodataViewModel(backToRoot: self?.onBackToRoot ?? {})
                                self?.route = .biodataTalent(viewModel: viewModel)
                                
                            }
                            
                        }
                        
                    } else {
                        self?.stateObservable.isVerified = VerifiedCondition.verifiedNoName
                        
                        if self?.stateObservable.userType == 3 {
                            let viewModel = BiodataViewModel(backToRoot: self?.onBackToRoot ?? {})
                            self?.route = .biodataUser(viewModel: viewModel)
                            
                        } else if self?.stateObservable.userType == 2 {
                            let viewModel = BiodataViewModel(backToRoot: self?.onBackToRoot ?? {})
                            self?.route = .biodataTalent(viewModel: viewModel)
                            
                        }
                        
                    }
                } else if !(data?.isPasswordFilled ?? false) && !(data?.name).orEmpty().isEmpty {
                    let viewModel = LoginPasswordResetViewModel(isFromHome: false, backToRoot: self?.onBackToRoot ?? {}, backToLogin: self?.backToLogin ?? {})
                    self?.route = .loginResetPassword(viewModel: viewModel)
                }
            case .none:
                break
            }
        }
    }
    
    func getUsers() {
        onStartFetch()
        
        userRepository
            .provideGetUsers()
            .sink { result in
                switch result {
                case .finished:
                    DispatchQueue.main.async { [weak self] in
                        self?.success = true
                        self?.isLoading = false
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {[weak self] in
                        self?.isError = true
                        self?.isLoading = false
                        self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
                        
                    }
                }
            } receiveValue: { value in
                self.routingPage(data: value, otpForget: nil)
            }
            .store(in: &cancellables)
        
    }
    
    func resendOtp() {
        onStartFetch()
        
			let phone = ResendOTPChannel(phone: phoneNumber, channel: selectedChannel.name)
        
        repository
            .resendOtp(with: phone)
            .sink { result in
                switch result {
                case .finished:
                    DispatchQueue.main.async { [weak self] in
                        self?.success = true
                        self?.isLoading = false
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {[weak self] in
                        self?.isError = true
                        self?.isLoading = false
                        self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
                        
                    }
                }
            } receiveValue: { _ in
                self.timeRemaining = 60
                self.isActive = false
            }
            .store(in: &cancellables)
    }
}
