//
//  ForgotPasswordViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/04/22.
//

import Foundation
import SwiftUI
import UIKit
import Combine
import CountryPicker
import DinotisData
import DinotisDesignSystem
import OneSignal

final class ForgotPasswordViewModel: ObservableObject {
	
	private let forgotPasswordUseCase: ForgotPasswordUseCase
	private var cancellables = Set<AnyCancellable>()
    private var stateObservable = StateObservable.shared
    
	@Published var countrySelected: Country = Country(phoneCode: "62", isoCode: "ID")
	@Published var isShowingCountryPicker = false
	@Published var selectedChannel: DeliveryOTPVia = .whatsapp
    
    @Published var isShowSelectChannel = false
	
	@Published var phone = ResendOtp(phone: "")
	@Published var offsetY = CGFloat.zero
	@Published var isLoading = false
	@Published var isError = false
	@Published var error: String?
	@Published var isRefreshFailed = false
	@Published var fieldError: [FieldError]?
	@Published var success: Bool = false
	@Published var statusCode = 0
	@Published var isShowError = false
	@Published var route: PrimaryRouting?
	@Published var phoneNumberError: [String]?
  
  @Published var isShowAlert = false
  @Published var alert = AlertAttribute()
	
	var backToRoot: () -> Void
	var backToLogin: () -> Void
	
	init(
        forgotPasswordUseCase: ForgotPasswordUseCase = ForgotPasswordDefaultUseCase(),
		backToRoot: @escaping (() -> Void),
		backToLogin: @escaping (() -> Void)
	) {
		self.backToRoot = backToRoot
		self.backToLogin = backToLogin
		self.forgotPasswordUseCase = forgotPasswordUseCase
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
			self?.phoneNumberError = nil
      self?.isShowAlert = false
      self?.alert = .init(
        isError: false,
        title: LocalizableText.attentionText,
        message: "",
        primaryButton: .init(
          text: LocalizableText.closeLabel,
          action: {}
        ),
        secondaryButton: nil
      )
		}
		
	}
	
	func openWhatsApp() {
		if let waurl = URL(string: "https://wa.me/6281318506068") {
			if UIApplication.shared.canOpenURL(waurl) {
				UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
			}
		}
	}

	func isButtonDisable() -> Bool {
		self.phone.phone.isEmpty
	}

	func flag(country:String) -> String {
		let base: UInt32 = 127397
		var flagCode = ""
		for v in country.unicodeScalars {
			flagCode.unicodeScalars.append(UnicodeScalar(base + v.value)!)
		}
		return String(flagCode)
	}
    
    func handleDefaultErrorCreate(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false

            if let error = error as? ErrorResponse {
                
                self?.statusCode = error.statusCode.orZero()

                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                  self?.alert.isError = true
                  self?.alert.message = LocalizableText.alertSessionExpired
                  self?.alert.primaryButton = .init(
                    text: LocalizableText.okText,
                    action: {
                        NavigationUtil.popToRootView()
                        self?.stateObservable.userType = 0
                        self?.stateObservable.isVerified = ""
                        self?.stateObservable.refreshToken = ""
                        self?.stateObservable.accessToken = ""
                        self?.stateObservable.isAnnounceShow = false
                        OneSignal.setExternalUserId("") }
                  )
                  self?.isShowAlert = true
                } else if error.statusCode.orZero() == 422 {
                    if let phoneError = error.fields?.filter({ $0.name.orEmpty().contains("phone") } ) {
                        self?.phoneNumberError = phoneError.compactMap({
                            $0.error.orEmpty()
                        })
                    }
                } else {
                    self?.error = error.message.orEmpty()
                    self?.isError = true
                  self?.alert.isError = true
                  self?.alert.message = error.message.orEmpty()
                  self?.isShowAlert = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
              self?.alert.isError = true
              self?.alert.message = error.localizedDescription
              self?.isShowAlert = true
            }

        }
    }
    
    func onSendReset() {
        Task { await sendResetPassword() }
    }
	
	func sendResetPassword() async {
		onStartRequest()
		
		var tempPhone = phone.phone
		
		if self.phone.phone.first == "0" {
			tempPhone = tempPhone.replacingCharacters(in: ...phone.phone.startIndex, with: "")
		}
		
		let phones = "+\(countrySelected.phoneCode)" + tempPhone
		
		let body = OTPRequest(phone: phones, channel: selectedChannel.name)
        
        let result = await forgotPasswordUseCase.execute(with: body)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.success = true
                self?.routeToOTP(phone: phones)
            }
        case .failure(let failure):
            handleDefaultErrorCreate(error: failure)
        }
		
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
