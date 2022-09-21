//
//  ChangePasswordViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/04/22.
//

import Foundation
import Combine

final class ChangesPasswordViewModel: ObservableObject {
	private let authRepository: AuthenticationRepository
	private var cancellables = Set<AnyCancellable>()
	private var stateObservable = StateObservable.shared
	
	@Published var isSecuredOld: Bool = true
	@Published var isSecured: Bool = true
	@Published var isSecuredRe: Bool = true
	
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
	@Published var error: HMError?
	@Published var isRefreshFailed = false
	@Published var fieldError: [FieldError]?
	@Published var success: Bool = false
	@Published var statusCode = 0
	@Published var isShowError = false
	@Published var isPassShow = false
	@Published var isRepeatPassShow = false
	@Published var route: PrimaryRouting?
	@Published var isShowingNotice = false
	
	var backToRoot: () -> Void
	
	init(
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		backToRoot: @escaping (() -> Void)
	) {
		self.backToRoot = backToRoot
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
	
	func resetPassword() {
		onStartRequest()
		
		let body = ChangePassword(oldPassword: oldPassword, password: newPassword, confirmPassword: confirmPassword)
		
		authRepository
			.changePassword(params: body)
			.sink(receiveCompletion: { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async { [weak self] in
						if self?.statusCode == 401 {
							self?.refreshToken(onComplete: self?.resetPassword ?? {})
						} else {
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
						
					}
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isLoading = false
						self?.success = true
					}
				}
			}, receiveValue: { _ in
				
			})
			.store(in: &cancellables)
	}
	
	func onStartRefresh() {
		self.isRefreshFailed = false
		self.isLoading = true
		self.success = false
		self.error = nil
	}
	
	func refreshToken(onComplete: @escaping (() -> Void)) {
		onStartRefresh()
		
		let refreshToken = authRepository.loadFromKeychain(forKey: KeychainKey.refreshToken)
		
		authRepository
			.refreshToken(with: refreshToken)
			.sink { result in
				switch result {
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						self?.isLoading = false
						onComplete()
					}
					
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						self?.isRefreshFailed = true
						self?.isLoading = false
						self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
					}
				}
			} receiveValue: { value in
				self.stateObservable.refreshToken = value.refreshToken
				self.stateObservable.accessToken = value.accessToken
			}
			.store(in: &cancellables)
		
	}
	
	func isPasswordSame() -> Bool {
		newPassword == confirmPassword
	}
}
