//
//  ChangePhoneVerifyViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 24/02/22.
//

import Foundation
import Combine
import DinotisDesignSystem
import DinotisData
import UIKit
import SwiftUI

final class ChangePhoneVerifyViewModel: ObservableObject {
	
	private let changePhoneVerificationUseCase: ChangePhoneVerificationUseCase
    private let resendOtpUseCase: ResendOTPUseCase
	
	private var cancellables = Set<AnyCancellable>()
	
	private var stateObservable = StateObservable.shared
	
	@Published var timeRemaining = 60
	@Published var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	@Published var isActive = false
	@Published var timesUp = false
	@Published var selectedChannel: DeliveryOTPVia = .whatsapp
	@Published var isShowSelectChannel = false
	
	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
    @Published var alertTitle: String?
	@Published var error: String?
	@Published var success: Bool = false
  
  @Published var isShowAlert = false
  @Published var alert = AlertAttribute()
	
	@Published var phoneNumber: String
	
	@Published var isRefreshFailed = false

	@Published var otpError: String? = nil
	@Published var otpNumber: String = ""
    
    @Published var isResendVerification = false
	
	var onBackToRoot: () -> Void
	var backToEditProfile: () -> Void
	
	init(
		phoneNumber: String,
		onBackToRoot: @escaping (() -> Void),
		backToEditProfile: @escaping (() -> Void),
        changePhoneVerificationUseCase: ChangePhoneVerificationUseCase = ChangePhoneVerificationDefaultUseCase(),
		resendOtpUseCase: ResendOTPUseCase = ResendOTPDefaultUseCase()
	) {
		self.phoneNumber = phoneNumber
		self.onBackToRoot = onBackToRoot
		self.backToEditProfile = backToEditProfile
		self.changePhoneVerificationUseCase = changePhoneVerificationUseCase
        self.resendOtpUseCase = resendOtpUseCase
	}
	
	func onReceiveTimer() {
		if self.timeRemaining > 0 {
			self.timeRemaining -= 1
		} else {
			self.isActive = true
		}
	}

	func openWhatsApp() {
		if let waurl = URL(string: "https://wa.me/6281318506068") {
			if UIApplication.shared.canOpenURL(waurl) {
				UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
			}
		}
	}

	func timeRemainingText() -> String {
		return isActive ? LocalizableText.linkResendOTPActive : LocalizableText.linkResendOTP(with: timeRemaining)
	}
	
	func validateOTP(by otp: String) async {
		if otp.count == 6 {
			
			let body = OTPVerificationRequest(phone: phoneNumber, otp: otp)
			
			await otpVerification(body: body)
		}
	}
	
	func onStartFetch() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
            self?.alertTitle = nil
			self?.success = false
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

	func validateOTP() async {
		if otpNumber.count == 6 {

			let body = OTPVerificationRequest(phone: phoneNumber, otp: otpNumber)

			await otpVerification(body: body)
		}
	}
    
    func handleDefaultError(error: Error) {
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
                    action: { self?.onBackToRoot() }
                  )
                  self?.isShowAlert = true
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
	
	func otpVerification(body: OTPVerificationRequest) async {
		onStartFetch()
        
        let result = await changePhoneVerificationUseCase.execute(with: body)
		
        switch result {
        case .success(let value):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
              self?.alert.isError = false
              self?.alert.title = LocalizableText.alertSuccessChangePhoneTitle
              self?.alert.message = LocalizableText.alertSuccessChangePhoneMessage + " \(value.phone.orEmpty())"
              self?.alert.primaryButton = .init(
                text: LocalizableText.okText,
                action: { self?.backToEditProfile() }
              )
              self?.isShowAlert = true
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
                
                self?.timeRemaining = 60
                self?.isActive = false
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
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
}
