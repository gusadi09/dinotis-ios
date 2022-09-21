//
//  ForgotPasswordViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/04/22.
//

import Foundation
import UIKit
import Combine
import CountryPicker

final class ForgotPasswordViewModel: ObservableObject {
	
	private let authRepository: AuthenticationRepository
	private var cancellables = Set<AnyCancellable>()

	@Published var countrySelected: Country = Country(phoneCode: "62", isoCode: "ID")
	@Published var isShowingCountryPicker = false
	@Published var selectedChannel: DeliveryOTPVia = .whatsapp
    
    @Published var isShowSelectChannel = false
	
	@Published var phone = ResendOtp(phone: "")
	@Published var offsetY = CGFloat.zero
	@Published var isLoading = false
	@Published var isError = false
	@Published var error: HMError?
	@Published var isRefreshFailed = false
	@Published var fieldError: [FieldError]?
	@Published var success: Bool = false
	@Published var statusCode = 0
	@Published var isShowError = false
	@Published var route: PrimaryRouting?
	
	var backToRoot: () -> Void
	var backToLogin: () -> Void
	
	init(
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		backToRoot: @escaping (() -> Void),
		backToLogin: @escaping (() -> Void)
	) {
		self.backToRoot = backToRoot
		self.backToLogin = backToLogin
		self.authRepository = authRepository
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
	
	func openWhatsApp() {
		if let waurl = URL(string: "https://wa.me/6281318506068") {
			if UIApplication.shared.canOpenURL(waurl) {
				UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
			}
		}
	}
	
	func sendResetPassword() {
		onStartRequest()
		
		var tempPhone = phone.phone
		
		if self.phone.phone.first == "0" {
			tempPhone = tempPhone.replacingCharacters(in: ...phone.phone.startIndex, with: "")
		}
		
		let phones = "+\(countrySelected.phoneCode)" + tempPhone
		
		let body = ResendOTPChannel(phone: phones, channel: selectedChannel.name)
		
		authRepository
			.forgetPassword(params: body)
			.sink(receiveCompletion: { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async { [weak self] in
						self?.isLoading = false
						self?.isError = true
						self?.statusCode = error.statusCode.orZero()
						
						self?.error = HMError.serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						
						if self?.statusCode != 422 && self?.statusCode != 0 {
							self?.isShowError = true
						}
						
						if error.fields != nil {
							self?.fieldError = error.fields
						}
					}
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isLoading = false
						self?.success = true
						self?.routeToOTP(phone: phones)
					}
				}
			}, receiveValue: { _ in
				
			})
			.store(in: &cancellables)
	}
	
	func routeToOTP(phone: String) {
		DispatchQueue.main.async {[weak self] in
			let viewModel = OtpVerificationViewModel(
				phoneNumber: phone,
				otpType: .forgetPassword,
				onBackToRoot: self?.backToRoot ?? {},
				backToLogin: self?.backToLogin ?? {},
				backToPhoneSet: { self?.route = nil }
			)
			
			self?.route = .verificationOtp(viewModel: viewModel)
		}
	}
}
