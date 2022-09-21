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

final class LoginViewModel: ObservableObject {
	
	private let repository: AuthenticationRepository
	private let userRepository: UsersRepository
	
	private var cancellables = Set<AnyCancellable>()
	
	@ObservedObject var stateObservable = StateObservable.shared
	
	@Published var phone: LoginBody = LoginBody(phone: "", role: 0, password: "")
	@Published var isRegister = false
	@Published var selectedChannel: DeliveryOTPVia = .whatsapp
	@Published var isShowSelectChannel = false

	@Published var countrySelected: Country = Country(phoneCode: "62", isoCode: "ID")
	@Published var isShowingCountryPicker = false
	
	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false
	@Published var statusCode = 0
	
	@Published var isPassShow = false
	
	@Published var isShowError = false
	
	@Published var isRefreshFailed = false
	
	@Published var fieldError: [FieldError]?
	
	@Published var route: PrimaryRouting?
	
	@Published var loginData: LoginResponseV2?
	
	@Published var showingPassField = false
	
	var backToRoot: (() -> Void)
	
	init(
		repository: AuthenticationRepository = AuthenticationDefaultRepository(),
		userRepository: UsersRepository = UsersDefaultRepository(),
		backToRoot: @escaping (() -> Void)
	) {
		self.repository = repository
		self.userRepository = userRepository
		self.backToRoot = backToRoot
		
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
			self?.fieldError = nil
		}
		
	}
	
	func loginTitleText() -> String {
		isRegister ? LocaleText.registerTitle : LocaleText.loginAsBasicUser
	}
	
	func loginButtonText() -> String {
		isRegister ? LocaleText.generalRegisterText : LocaleText.generalLoginText
	}
	
	func firstBottomLineText() -> String {
		isRegister ? LocaleText.registerLoginFirst : LocaleText.loginRegisterFirst
	}
	
	func secondBottomLine() -> String {
		isRegister ? LocaleText.registerLoginSecond : LocaleText.loginRegisterSecond
	}
	
	func login(usertype: UserType) {
		onStartRequest()
		
		var tempPhone = phone.phone
		
		if self.phone.phone.first == "0" {
			tempPhone = tempPhone.replacingCharacters(in: ...phone.phone.startIndex, with: "")
		}
		
		let phones = "+\(countrySelected.phoneCode)" + tempPhone
		
		let body = LoginBodyV2(phone: phones, role: phone.role, password: phone.password.isEmpty ? nil : phone.password)
		
		repository
			.login(parameters: body)
			.sink(receiveCompletion: { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async { [weak self] in
						self?.isLoading = false
						self?.statusCode = error.statusCode.orZero()
						
						self?.error = HMError.serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						
						if self?.statusCode != 422 && self?.statusCode != 0 {
							self?.isShowError = true
						} else {
							self?.isError = true
						}
						
						if error.fields != nil {
							self?.fieldError = error.fields
						}
					}
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isLoading = false
						self?.success = true
						
						self?.stateObservable.userType = usertype.rawValue
					}
				}
			}, receiveValue: { [weak self] value in
				self?.loginData = value
				
				if (self?.isGoToOTPFromLogin(response: value) ?? false) {
					self?.routingPage(phone:  body.phone)
				} else if value.token != nil && value.data == nil {
					self?.stateObservable.accessToken = (value.token?.accessToken).orEmpty()
					self?.stateObservable.refreshToken = (value.token?.refreshToken).orEmpty()
					self?.stateObservable.isVerified = "Verified"
					
					self?.routeToHome()
				} else {
					self?.showingPassField.toggle()
				}
			})
			.store(in: &cancellables)
	}
	
	func isGoToOTPFromLogin(response: LoginResponseV2) -> Bool {
		(((response.data?.isDataFilled ?? false) && !(response.data?.isPasswordFilled ?? false)) ||  (!(response.data?.isDataFilled ?? false) && !(response.data?.isPasswordFilled ?? false))) && response.data != nil
	}
	
	func register() {
		onStartRequest()
		
		var tempPhone = phone.phone
		
		if self.phone.phone.first == "0" {
			tempPhone = tempPhone.replacingCharacters(in: ...phone.phone.startIndex, with: "")
		}
		
		let phones = "+\(countrySelected.phoneCode)" + tempPhone
		
		let body = ResendOTPChannel(phone: phones, channel: selectedChannel.name)
		
		repository.register(params: body)
			.sink(receiveCompletion: { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async { [weak self] in
						self?.isLoading = false

						self?.statusCode = error.statusCode.orZero()
						
						self?.error = HMError.serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						
						if self?.statusCode != 422 && self?.statusCode != 0 {
							self?.isShowError = true
						} else {
							self?.isError = true
						}
						
						if error.fields != nil {
							self?.fieldError = error.fields
						}
					}
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isLoading = false
						self?.success = true
						
						self?.routingPage(phone: phones)
					}
				}
			}, receiveValue: { _ in
				
			})
			.store(in: &cancellables)
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
			
			if self?.stateObservable.userType == 3 {
				let viewModel = UserHomeViewModel(backToRoot: self?.backToRoot ?? {})
				
				self?.route = .homeUser(viewModel: viewModel)
			} else if self?.stateObservable.userType == 2 {
				let viewModel = TalentHomeViewModel(backToRoot: self?.backToRoot ?? {})
				
				self?.route = .homeTalent(viewModel: viewModel)
			}
		}
	}
	
	func loginErrorTextForTalent() -> String {
		statusCode == 401 ? LocaleText.talentNotRegisterError : (error?.errorDescription).orEmpty()
	}
	
	func goToGoogleForm() {
		if let url = URL(string: "https://bit.ly/CommunityDinotis") {
			if UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
	
	func refreshToken() {
		onStartRequest()
		
		repository
			.refreshToken(with: stateObservable.refreshToken)
			.sink { result in
				switch result {
				case .failure(_):
					DispatchQueue.main.async { [weak self] in
						self?.isLoading = false
						self?.isRefreshFailed = true
					}
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
					}
				}
			} receiveValue: {[weak self] value in
				self?.stateObservable.accessToken = value.accessToken
				self?.stateObservable.refreshToken = value.refreshToken
			}
			.store(in: &cancellables)
	}
	
	func onDisappearView() {
		self.phone = LoginBody(phone: "", role: 0, password: "")
	}
}
