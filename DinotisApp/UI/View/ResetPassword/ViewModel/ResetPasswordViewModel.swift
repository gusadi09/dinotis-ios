//
//  ResetPasswordViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/04/22.
//

import Combine
import DinotisDesignSystem
import SwiftUI
import UIKit
import DinotisData
import DinotisDesignSystem
import OneSignal

final class ResetPasswordViewModel: ObservableObject {
	private let resetPasswordUseCase: ResetPasswordUseCase
	private var cancellables = Set<AnyCancellable>()
    private var stateObservable = StateObservable.shared
    
	@Published var password = ResetPasswordRequest(phone: "", password: "", passwordConfirm: "", token: "")
	@Published var isLoading = false
	@Published var isError = false
    @Published var alertTitle: String?
	@Published var error: String?
	@Published var isRefreshFailed = false
	@Published var fieldError: [FieldError]?
	@Published var success: Bool = false
	@Published var statusCode = 0
	@Published var isShowError = false
	@Published var isPassShow = true
	@Published var isRepeatPassShow = true
  
  @Published var isShowAlert = false
  @Published var alert = AlertAttribute()

	@Published var passwordError: [String]?
	@Published var rePasswordError: [String]?
	
	@Published var passValid = true
	@Published var passValidMsg = ""
	
	@Published var rePassValid = true
	@Published var rePassValidMsg = ""
	
	@Published var validator: (valid: Bool, message: String) = (valid: true, message: "")
	
	var backToRoot: () -> Void
	var backToLogin: () -> Void
	var backToPhoneSet: () -> Void
	
	init(
		phone: String,
		token: String,
        resetPasswordUseCase: ResetPasswordUseCase = ResetPasswordDefaultUseCase(),
		backToRoot: @escaping (() -> Void),
		backToLogin: @escaping (() -> Void),
		backToPhoneSet: @escaping (() -> Void)
	) {
		self.backToRoot = backToRoot
		self.backToLogin = backToLogin
		self.backToPhoneSet = backToPhoneSet
		self.resetPasswordUseCase = resetPasswordUseCase
		self.password.phone = phone
		self.password.token = token
	}

	func openWhatsApp() {
		if let waurl = URL(string: "https://wa.me/6281318506068") {
			if UIApplication.shared.canOpenURL(waurl) {
				UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
			}
		}
	}

	func isButtonDisable() -> Bool {
		self.password.password.isEmpty || self.password.passwordConfirm.isEmpty
	}
	
	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
            self?.alertTitle = nil
			self?.success = false
			self?.statusCode = 0
			self?.isRefreshFailed = false
			self?.isShowError = false
			self?.fieldError = nil
			self?.passwordError = nil
			self?.rePasswordError = nil
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
    
    func handleDefaultErrorCreate(error: Error) {
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
                    if let passError = error.fields?.filter({ $0.name.orEmpty() == "password" }) {
                        self?.passwordError = passError.compactMap {
                            $0.error.orEmpty()
                        }

                    } else {
                        self?.passwordError = nil
                    }

                    if let repassError = error.fields?.filter({ $0.name.orEmpty() == "passwordConfirm" }) {
                        self?.rePasswordError = repassError.compactMap {
                            $0.error.orEmpty()
                        }

                    } else {
                        self?.passwordError = nil
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
	
    func resetPassword() async  {
        onStartRequest()
        
        let result = await resetPasswordUseCase.execute(with: password)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.success = true
              self?.alert.isError = false
              self?.alert.title = LocalizableText.titleChangePasswordDialogSuccess
              self?.alert.message = LocalizableText.descriptionChangePasswordDialogSuccess
              self?.alert.primaryButton = .init(
                text: LocalizableText.okText,
                action: {self?.backToLogin()}
              )
              self?.isShowAlert = true
            }
        case .failure(let failure):
            handleDefaultErrorCreate(error: failure)
        }
    }
	
	func isPasswordSame() -> Bool {
		password.password == password.passwordConfirm
	}
}
