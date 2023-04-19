//
//  ChangePhoneViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 24/02/22.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import CountryPicker
import DinotisData
import DinotisDesignSystem
import OneSignal

final class ChangePhoneViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	var backToEditProfile: () -> Void
	
	private var cancellables = Set<AnyCancellable>()
	
	private var stateObservable = StateObservable.shared
	
	private let changePhoneUseCase: ChangePhoneUseCase
	
	@Published var route: HomeRouting?

	@Published var countrySelected: Country = Country(phoneCode: "62", isoCode: "ID")
	@Published var isShowingCountryPicker = false
    @Published var isShowSelectChannel = false
	
	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: String?
	@Published var success: Bool = false
  
  @Published var isShowAlert = false
  @Published var alert = AlertAttribute()
	
	@Published var phone = ""
	@Published var isRefreshFailed = false
	
	@Published var fieldError: [FieldError]?
	@Published var isShowError = false

	@Published var selectedChannel: DeliveryOTPVia = .whatsapp

	@Published var phoneNumberError: [String]?
	
	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		backToEditProfile: @escaping (() -> Void),
        phone: String,
        changePhoneUseCase: ChangePhoneUseCase = ChangePhoneDefaultUseCase()
	) {
		self.backToHome = backToHome
		self.backToRoot = backToRoot
        self.phone = phone
		self.backToEditProfile = backToEditProfile
		self.changePhoneUseCase = changePhoneUseCase
		
	}

	func isButtonDisable() -> Bool {
		self.phone.isEmpty
	}

	func flag(country:String) -> String {
		let base: UInt32 = 127397
		var flagCode = ""
		for v in country.unicodeScalars {
			flagCode.unicodeScalars.append(UnicodeScalar(base + v.value)!)
		}
		return String(flagCode)
	}
	
	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.success = false
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.fieldError = nil
			self?.isShowError = false
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
    
    func handleDefaultErrorSend(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false

            if let error = error as? ErrorResponse {

                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                  self?.alert.isError = true
                  self?.alert.message = LocalizableText.alertSessionExpired
                  self?.alert.primaryButton = .init(
                    text: LocalizableText.okText,
                    action: {
                      self?.stateObservable.userType = 0
                      self?.stateObservable.isVerified = ""
                      self?.stateObservable.refreshToken = ""
                      self?.stateObservable.accessToken = ""
                      self?.stateObservable.isAnnounceShow = false
                      OneSignal.setExternalUserId("")
                      self?.backToRoot()
                    }
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
    
    func onGetOTP() {
        Task {
            await getOtpCode()
        }
    }
	
	func getOtpCode() async {
		onStartRequest()
		
		var tempPhone = phone
		
		if self.phone.first == "0" {
			tempPhone = tempPhone.replacingCharacters(in: ...phone.startIndex, with: "")
		}
		
		let phones = "+\(countrySelected.phoneCode)" + tempPhone
		let body = OTPRequest(phone: phones, channel: selectedChannel.name)
        
        let result = await changePhoneUseCase.execute(with: body)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async {[weak self] in
                self?.isLoading = false
                self?.success = true
                
                self?.routeToOtp()
            }
        case .failure(let failure):
            handleDefaultErrorSend(error: failure)
        }
	}
	
	func onStartRefresh() {
    DispatchQueue.main.async { [weak self] in
      self?.isRefreshFailed = false
      self?.isLoading = true
      self?.success = false
      self?.error = nil
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
	
	func routeToOtp() {
		var tempPhone = phone
		
		if self.phone.first == "0" {
			tempPhone = tempPhone.replacingCharacters(in: ...phone.startIndex, with: "")
		}
		
		let phones = "+\(countrySelected.phoneCode)" + tempPhone
		
		let viewModel = ChangePhoneVerifyViewModel(phoneNumber: phones, onBackToRoot: self.backToRoot, backToEditProfile: self.backToEditProfile)
		
		DispatchQueue.main.async {[weak self] in
			self?.route = .changePhoneOtp(viewModel: viewModel)
		}
	}
}
