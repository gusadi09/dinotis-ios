//
//  ResetPasswordViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/04/22.
//

import Foundation
import Combine

final class ResetPasswordViewModel: ObservableObject {
	private let authRepository: AuthenticationRepository
	private var cancellables = Set<AnyCancellable>()
	
	@Published var password = ResetPasswordBody(phone: "", password: "", passwordConfirm: "", token: "")
	@Published var isLoading = false
	@Published var isError = false
	@Published var error: HMError?
	@Published var isRefreshFailed = false
	@Published var fieldError: [FieldError]?
	@Published var success: Bool = false
	@Published var statusCode = 0
	@Published var isShowError = false
	@Published var isPassShow = false
	@Published var isRepeatPassShow = false
	
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
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		backToRoot: @escaping (() -> Void),
		backToLogin: @escaping (() -> Void),
		backToPhoneSet: @escaping (() -> Void)
	) {
		self.backToRoot = backToRoot
		self.backToLogin = backToLogin
		self.backToPhoneSet = backToPhoneSet
		self.authRepository = authRepository
		self.password.phone = phone
		self.password.token = token
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
	
	func resetPassword() {
		onStartRequest()
		
		authRepository
			.resetPassword(params: password)
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
						self?.backToLogin()
					}
				}
			}, receiveValue: { _ in
				
			})
			.store(in: &cancellables)
	}
	
	func isPasswordSame() -> Bool {
		password.password == password.passwordConfirm
	}
}
