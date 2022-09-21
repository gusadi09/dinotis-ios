//
//  LoginPasswordResetViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/04/22.
//

import Foundation
import Combine
import OneSignal

final class LoginPasswordResetViewModel: ObservableObject {
	private let authRepository: AuthenticationRepository
	private var cancellables = Set<AnyCancellable>()
	private var stateObservable = StateObservable.shared
	@Published var isFromHome: Bool
	
	@Published var password = ChangePassword(password: "", confirmPassword: "")
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
	
	@Published var passValid = true
	@Published var passValidMsg = ""
	
	@Published var rePassValid = true
	@Published var rePassValidMsg = ""
	
	@Published var validator: (valid: Bool, message: String) = (valid: true, message: "")
	
	var backToRoot: () -> Void
	var backToLogin: () -> Void
	
	init(
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		isFromHome: Bool,
		backToRoot: @escaping (() -> Void),
		backToLogin: @escaping (() -> Void)
	) {
		self.backToRoot = backToRoot
		self.backToLogin = backToLogin
		self.authRepository = authRepository
		self.isFromHome = isFromHome
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
	
	func resetState() {
		stateObservable.refreshToken = ""
		stateObservable.accessToken = ""
		stateObservable.userType = 0
		stateObservable.isVerified = ""
		stateObservable.isAnnounceShow = false
	}
	
	func resetPassword() {
		onStartRequest()
		
		authRepository
			.changePassword(params: password)
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
						self?.routeToHome()
					}
				}
			}, receiveValue: { _ in
				
			})
			.store(in: &cancellables)
	}
	
	func isPasswordSame() -> Bool {
		password.password == password.confirmPassword
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
}
