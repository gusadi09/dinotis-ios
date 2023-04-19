//
//  ChangePasswordViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/04/22.
//

import DinotisData
import DinotisDesignSystem
import Foundation
import UIKit
import SwiftUI
import Combine
import OneSignal

final class ChangesPasswordViewModel: ObservableObject {
    private let changePasswordUseCase: ChangePasswordUseCase
    private var cancellables = Set<AnyCancellable>()
    private var stateObservable = StateObservable.shared
    
    @Published var isSecuredOld: Bool = true
    @Published var isSecured: Bool = true
    @Published var isSecuredRe: Bool = true
    
    @Published var oldPasswordError: [String]?
    @Published var newPasswordError: [String]?
    @Published var newRePasswordError: [String]?
    
    @Published var oldPassValid = true
    @Published var oldPassValidMsg = ""
    
    @Published var passValid = true
    @Published var passValidMsg = ""
    
    @Published var rePassValid = true
    @Published var rePassValidMsg = ""
    
    @Published var validator: (valid: Bool, message: String) = (valid: true, message: "")
    
    @Published var oldPassword = ""
    @Published var newPassword = ""
    
    @Published var confirmPassword = ""
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var error: String?
    @Published var isRefreshFailed = false
    @Published var fieldError: [FieldError]?
    @Published var success: Bool = false
    @Published var statusCode = 0
    @Published var isShowError = false
    @Published var route: PrimaryRouting?
    @Published var isShowingNotice = false
    
    @Published var isShowAlert = false
    @Published var alert = AlertAttribute()
    
    var backToRoot: () -> Void
    
    init(
        changePasswordUseCase: ChangePasswordUseCase = ChangePasswordDefaultUseCase(),
        backToRoot: @escaping (() -> Void)
    ) {
        self.backToRoot = backToRoot
        self.changePasswordUseCase = changePasswordUseCase
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
            self?.newPasswordError = nil
            self?.oldPasswordError = nil
            self?.newRePasswordError = nil
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
        self.oldPassword.isEmpty || self.newPassword.isEmpty || self.confirmPassword.isEmpty
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
                        action: { self?.backToRoot() }
                    )
                    self?.isShowAlert = true
                } else if error.statusCode.orZero() == 422 {
                    if let oldPassError = error.fields?.filter({ $0.name.orEmpty() == "oldPassword" } ) {
                        self?.oldPasswordError = oldPassError.compactMap({
                            $0.error.orEmpty()
                        })
                    }
                    
                    if let passError = error.fields?.filter({ $0.name.orEmpty() == "password" } ) {
                        self?.newPasswordError = passError.compactMap({
                            $0.error.orEmpty()
                        })
                    }
                    
                    if let rePassError = error.fields?.filter({ $0.name.orEmpty() == "confirmPassword" } ) {
                        self?.newRePasswordError = rePassError.compactMap({
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
    
    func onStartRefresh() {
        DispatchQueue.main.async { [weak self] in
            self?.isRefreshFailed = false
            self?.isLoading = true
            self?.success = false
            self?.error = nil
            self?.isError = false
            self?.alert = .init(
                isError: false,
                title: "",
                message: "",
                primaryButton: .init(text: LocalizableText.okText, action: {}),
                secondaryButton: nil
            )
        }
    }
    
    func resetPassword(dismiss: @escaping () -> Void) async {
        onStartRequest()
        
        let body = ChangePasswordRequest(oldPassword: oldPassword, password: newPassword, confirmPassword: confirmPassword)
        
        let result = await changePasswordUseCase.execute(with: body)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    self?.isLoading = false
                    self?.success = true
                    self?.alert.isError = false
                    self?.alert.title = LocalizableText.titleChangePasswordDialogSuccess
                    self?.alert.message = LocalizableText.descriptionChangePasswordDialogSuccess
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: dismiss
                    )
                    self?.isShowAlert = true
                }
            }
        case .failure(let failure):
            handleDefaultErrorCreate(error: failure)
        }
    }
    
    func isPasswordSame() -> Bool {
        newPassword == confirmPassword
    }
}
