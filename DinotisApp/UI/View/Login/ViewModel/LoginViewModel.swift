//
//  LoginViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/09/21.
//

import Foundation
import SwiftKeychainWrapper
import SwiftUI
import Combine
import CountryPicker
import DinotisDesignSystem
import DinotisData

final class LoginViewModel: ObservableObject {
	
	private let repository: AuthenticationRepository
	private let userRepository: UsersRepository
	
	private var cancellables = Set<AnyCancellable>()

	private let loginUseCase: LoginUseCase
	private let registerUseCase: RegisterUseCase
	
	@ObservedObject var stateObservable = StateObservable.shared
	
	@Published var phone = LoginRequest(phone: "", role: 0, password: "")
	@Published var isRegister = false
	@Published var selectedChannel: DeliveryOTPVia = .whatsapp
	@Published var isShowSelectChannel = false
	@Published var invitationCode = ""
	@Published var isShowRequestInvitation = false

	@Published var countrySelected: Country = Country(phoneCode: "62", isoCode: "ID")
	@Published var isShowingCountryPicker = false
    
    @Published var isShowTerms = false
	
	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: String?
	@Published var success: Bool = false
	@Published var statusCode = 0
    
    @Published var isPasswordError = false
    @Published var isPhoneNumberError = false
	
	@Published var isPassShow = false
    @Published var isSecure = true
	
	@Published var isShowError = false
	
	@Published var isRefreshFailed = false
    
    @Published var phoneNumberError: [String]? = nil
    @Published var passwordError: [String]? = nil
	@Published var invitationError: [String]? = nil
	
	@Published var route: PrimaryRouting?
	
	@Published var showingPassField = false
	
	var backToRoot: (() -> Void)
	
	init(
		loginUseCase: LoginUseCase = LoginDefaultUseCase(),
		registerUseCsae: RegisterUseCase = RegisterDefaultUseCase(),
		repository: AuthenticationRepository = AuthenticationDefaultRepository(),
		userRepository: UsersRepository = UsersDefaultRepository(),
		backToRoot: @escaping (() -> Void)
	) {
		self.loginUseCase = loginUseCase
		self.registerUseCase = registerUseCsae
		self.repository = repository
		self.userRepository = userRepository
		self.backToRoot = backToRoot
		
	}

	func resetAllError() {
		DispatchQueue.main.async {[weak self] in
			self?.isPasswordError = false
			self?.isPhoneNumberError = false
			self?.phoneNumberError = nil
			self?.passwordError = nil
			self?.invitationError = nil
		}
	}

	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.success = false
			self?.statusCode = 0
			self?.isRefreshFailed = false
			self?.isShowError = false
            self?.isPasswordError = false
            self?.isPhoneNumberError = false
            self?.phoneNumberError = nil
            self?.passwordError = nil
		}
		
	}
	
	func loginTitleText() -> String {
        if stateObservable.userType == 2 {
            return isRegister ? LocalizableText.titleRegisterCreator : LocalizableText.loginTitle
        } else {
            return isRegister ? LocalizableText.titleRegisterAudience : LocalizableText.loginTitle
        }
	}
    
    func loginDescriptionText() -> String {
        if stateObservable.userType == 2 {
            return isRegister ? LocalizableText.descriptionRegisterCreator : LocalizableText.loginDescription
        } else {
            return isRegister ? LocalizableText.descriptionRegister : LocalizableText.loginDescription
        }
    }
	
    func loginButtonText() -> String {
        return isRegister ? LocalizableText.labelSendOTP : LocalizableText.loginLabel
    }
	
	func firstBottomLineText() -> String {
		isRegister ? LocalizableText.linkLoginHere : LocalizableText.linkRegisterHere
	}
	
	func secondBottomLine() -> String {
		isRegister ? LocalizableText.linkLoginHereHighlighted : LocalizableText.linkRegisterHereHighlighted
	}
    
    func flag(country:String) -> String {
        let base: UInt32 = 127397
        var flagCode = ""
        for v in country.unicodeScalars {
            flagCode.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(flagCode)
    }
    
    func termsURL() -> URL {
        return URL(string: "https://y.dinotis.com/terms")!
    }

	func invitationURL() -> URL {
		return URL(string: "https://y.dinotis.com/community")!
	}
    
    func registerButtonAction() async {
        if !isRegister {
            if stateObservable.userType == 3 {
                phone.role = 3
                
                await login(with: .basicUser)
            }
            
            if stateObservable.userType == 2 {
                phone.role = 2
                
                await login(with: .talent)
            }
        } else {
            isShowSelectChannel.toggle()
        }
    }
    
    func isButtonDisable() -> Bool {
		if stateObservable.userType == 2 {
			return (isRegister ? (phone.phone.isEmpty || invitationCode.isEmpty) : (phone.password.isEmpty || phone.phone.isEmpty))
		} else {
			return (isRegister ? phone.phone.isEmpty : (phone.password.isEmpty || phone.phone.isEmpty))
		}
    }

	func login(with type: UserType) async {
		
		onStartRequest()

		let result = await loginUseCase.execute(by: phone.processedRequest(country: countrySelected.phoneCode), type: type)

		switch result {
		case .success:
			DispatchQueue.main.async { [weak self] in
				self?.isLoading = false
				self?.success = true

				self?.routeToHome()
			}
		case .failure(let failure):
			if let error = failure as? ErrorResponse {
				handleLoginError(error: error)
			} else {
				handleDefaultError(error: failure)
			}

		}
	}

	func register() async {
		onStartRequest()

		let otp = OTPRequest(phone: phone.phone, channel: selectedChannel.name, invitationCode: invitationCode).processedRequest(country: countrySelected.phoneCode, type: stateObservable.userType)

		let result = await registerUseCase.execute(by: otp)

		switch result {
		case .success(_):
			DispatchQueue.main.async { [weak self] in
				self?.isLoading = false
				self?.success = true

				self?.routingPage(phone: otp.phone)
			}
		case .failure(let failure):
			if let error = failure as? ErrorResponse {
				handleRegisterError(error: error)
			} else {
				handleDefaultError(error: failure)
			}
		}
	}

	func doRegister() {
		if self.isRegister {
			Task {
                self.isShowSelectChannel = false
				await self.register()
			}
		}
	}

	func handleDefaultError(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoading = false
			self?.isError = true

			self?.error = error.localizedDescription
		}
	}

	func handleLoginError(error: ErrorResponse) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoading = false
			self?.statusCode = error.statusCode.orZero()

			self?.error = error.message.orEmpty()

			if self?.statusCode == 401 {
				if error.errorCode == "INCORRECT_PASSWORD" {
					self?.isPasswordError = true
					self?.passwordError = [LocalizableText.alertPasswordWrong]
				}
				if error.errorCode == "USER_NOT_REGISTERED" || error.errorCode == "TALENT_NOT_REGISTERED" {
					self?.isPhoneNumberError = true
					self?.phoneNumberError = [LocalizableText.alertPhoneUnregister]
				}
			} else if self?.statusCode == 422 {
				if let phoneError = error.fields?.filter({ $0.name.orEmpty().contains("phone") }) {
					self?.phoneNumberError = phoneError.compactMap({
						$0.error.orEmpty()
					})
				}

				if let passwordError = error.fields?.filter({ $0.name.orEmpty().contains("password")}) {
					self?.passwordError = passwordError.compactMap({
						$0.error.orEmpty()
					})
					self?.isPasswordError = true
				}
			} else {
				withAnimation {
					self?.isError = true
					self?.isShowError = true
				}

			}
		}
	}

	func handleRegisterError(error: ErrorResponse) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoading = false

			self?.statusCode = error.statusCode.orZero()

			self?.error = error.message.orEmpty()

			if self?.statusCode == 401 {
				if error.errorCode == "USER_ALREADY_REGISTERED" {
					self?.isPhoneNumberError = true
                    self?.phoneNumberError = []
					self?.phoneNumberError?.append(LocalizableText.alertPhoneAlreadyRegistered)
				}
			} else if self?.statusCode == 422 {
				print(error)
				if let phoneError = error.fields?.filter({ $0.name.orEmpty().contains("phone")}) {
					self?.phoneNumberError = phoneError.compactMap({
						$0.error.orEmpty()
					})
					self?.isPhoneNumberError = true
				}

				if let invitationError = error.fields?.filter({ $0.name.orEmpty() == "invitationCode" }) {
					self?.invitationError = invitationError.compactMap({
						$0.error.orEmpty()
					})
				}
			} else {
				withAnimation {
					self?.isError = true
					self?.isShowError = true
				}
			}
		}
	}
	
	func routingPage(phone: String) {
		DispatchQueue.main.async { [weak self] in
			
			let viewModel = OtpVerificationViewModel(
				phoneNumber: phone,
				otpType: (self?.isRegister ?? false) ? .register : .login,
				onBackToRoot: self?.backToRoot ?? {},
				backToLogin: { self?.route = nil },
				backToPhoneSet: {}
			)
			
			self?.route = .verificationOtp(viewModel: viewModel)
		}
	}
	
	func routeToHome() {
        DispatchQueue.main.async { [weak self] in
            
            let vm = TabViewContainerViewModel(
                isFromUserType: true,
                talentHomeVM: TalentHomeViewModel(isFromUserType: true),
                userHomeVM: UserHomeViewModel(),
                profileVM: ProfileViewModel(backToHome: {}),
                searchVM: SearchTalentViewModel(backToHome: {}),
                scheduleVM: ScheduleListViewModel(backToHome: {}, currentUserId: "")
            )
            
            DispatchQueue.main.async { [weak self] in
                self?.route = .tabContainer(viewModel: vm)
            }
        }
    }
    
	func loginErrorTextForTalent() -> String {
		statusCode == 401 ? LocaleText.talentNotRegisterError : error.orEmpty()
	}
	
	func goToGoogleForm() {
		if let url = URL(string: "https://bit.ly/CommunityDINOTIS") {
			if UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
	}
    
    func openWhatsApp() {
        if let waurl = URL(string: "https://wa.me/6281318506068") {
            if UIApplication.shared.canOpenURL(waurl) {
                UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
            }
        }
    }
	
	func routeToForgot() {
		DispatchQueue.main.async { [weak self] in
			
			let viewModel = ForgotPasswordViewModel(
				backToRoot: self?.backToRoot ?? {},
				backToLogin: { self?.route = nil }
			)
			
			self?.route = .forgotPassword(viewModel: viewModel)
		}
	}
	
	func onDisappearView() {
		self.phone = LoginRequest(phone: "", role: 0, password: "")
	}
}
