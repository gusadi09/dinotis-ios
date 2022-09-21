//
//  UsernameViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/10/21.
//

import Foundation
import SwiftKeychainWrapper

class UsernameViewModel: ObservableObject {

	let authService = AuthService.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var success: Bool = false
	@Published var suggestSuccess: Bool = false
	@Published var error: HMError?

	@Published var statusCode = 0
	let stateObservable = StateObservable.shared

	@Published var username = ""

	@Published var isRefreshFailed = false

	func usernameAvailability(with username: String) {
		let usernameBody = UsernameBody(username: username)
		self.isLoading = true
		self.success = false
		self.isError = false
		self.error = nil
		self.isRefreshFailed = false

		authService.usernameAvailability(token: stateObservable.accessToken, username: usernameBody) { result, error  in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.success = true
				}
			} else {
				if let error = error {
					if error.statusCode == 401 {
						self.authService.refreshToken(with: self.stateObservable.refreshToken) { response in
							switch response {
								case .failure(_):
									DispatchQueue.main.async {
										self.isLoading = false
										self.isRefreshFailed = true
									}
								case .success(let response):
									self.stateObservable.accessToken = response.accessToken
									self.stateObservable.refreshToken = response.refreshToken

									self.usernameAvailability(with: username)
							}
						}
					} else {
						DispatchQueue.main.async {
							self.isLoading = false
							self.isError = true
							self.success = false

							self.error = HMError.serverError(code: error.statusCode ?? 0, message: error.message ?? "")
						}
					}
				}
			}
		}
	}

	func usernameAvailabilityEdit(with username: String) {
		let usernameBody = UsernameBody(username: username)
		self.isLoading = true
		self.success = false
		self.isError = false
		self.error = nil
		self.statusCode = 0
		self.isRefreshFailed = false

		authService.usernameAvailabilityEdit(token: stateObservable.accessToken, username: usernameBody) { result, error  in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.success = true

					self.statusCode = 204
				}
			} else {
				if let error = error {
					if error.statusCode == 401 {
						self.authService.refreshToken(with: self.stateObservable.refreshToken) { response in
							switch response {
								case .failure(_):
									DispatchQueue.main.async {
										self.isLoading = false
										self.isRefreshFailed = true
									}
								case .success(let response):
									self.stateObservable.accessToken = response.accessToken
									self.stateObservable.refreshToken = response.refreshToken

									self.usernameAvailabilityEdit(with: username)
							}
						}
					} else {
						DispatchQueue.main.async {
							self.isLoading = false
							self.isError = true
							self.success = false
							self.statusCode = error.statusCode ?? 0

							self.error = HMError.serverError(code: error.statusCode ?? 0, message: error.message ?? "")
						}
					}
				}
			}
		}
	}

	func usernameSuggestion(with name: String) {
		let suggestBody = SuggestionBody(name: name)
 		self.isLoading = true
		self.success = false
		self.isError = false
		self.error = nil
		self.suggestSuccess = false
		self.isRefreshFailed = false

		authService.usernameSuggestion(token: stateObservable.accessToken, name: suggestBody) { result, error  in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.success = true
					self.suggestSuccess = true

					self.username = result?.username ?? ""
				}
			} else {
				if let error = error {
					if error.statusCode == 401 {
						self.authService.refreshToken(with: self.stateObservable.refreshToken) { response in
							switch response {
								case .failure(_):
									DispatchQueue.main.async {
										self.isLoading = false
										self.isRefreshFailed = true
									}
								case .success(let response):
									self.stateObservable.accessToken = response.accessToken
									self.stateObservable.refreshToken = response.refreshToken

									self.usernameSuggestion(with: name)
							}
						}
					} else {
						DispatchQueue.main.async {
							self.isLoading = false
							self.isError = true
							self.success = false

							self.error = HMError.serverError(code: error.statusCode ?? 0, message: error.message ?? "")
						}
					}
				}
			}
		}
	}
}
