//
//  UsersViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/09/21.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper

class UsersViewModel: ObservableObject {
	static let shared = UsersViewModel()

	let authService = AuthService.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var success: Bool = false
	@Published var error: HMError?
	@Published var statusCode = 0

	@Published var data: Users?

	@Published var currentBalances: Int = 0

	@Published var toNextView = false
	@Published var toNextVerif = false
	@Published var toBio = false
	@Published var toHome = false

	@Published var isReachable = 0

	@Published var isVerified: String {
		didSet {
			UserDefaults.standard.set(isVerified, forKey: KeychainKey.isVerified)
		}
	}

	@Published var isRefreshFailed = false

	let stateObservable = StateObservable.shared

	init() {
		self.isVerified = UserDefaults.standard.object(forKey: KeychainKey.isVerified) as? String ?? ""
	}

	func onStartFetch() {
		self.isLoading = true
		self.isError = false
		self.error = nil
		self.toNextView = false
		self.toNextVerif = false
		self.toBio = false
		self.success = false
		statusCode = 0
		self.isRefreshFailed = false
	}

	func getUsers() {
		onStartFetch()

		authService.getUser(token: stateObservable.accessToken) { response, error in
			if response != nil {
					DispatchQueue.main.async {
						self.isLoading = false
						self.success = true

						self.data = response

						if (response?.emailVerifiedAt != nil) && (!(response?.name!.isEmpty ?? true)) {
							self.isVerified = "Verified"
							self.toNextView = true
							self.toNextVerif = false
						} else if (response?.emailVerifiedAt != nil) && ((response?.name!.isEmpty) != nil) {
							self.isVerified = VerifiedCondition.verifiedNoName
							self.toNextView = false
							self.toNextVerif = false
							self.toBio = true
						} else {
							self.isVerified = ""
							self.toNextView = false
							self.toNextVerif = true
						}

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

									self.getUsers()
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

	func onStartFetchBalance() {
		self.isLoading = true
		self.isError = false
		self.success = false
		self.error = nil
		statusCode = 0
		self.isRefreshFailed = false
	}

	func currentBalance() {
		onStartFetchBalance()

		authService.currentBalance(token: stateObservable.accessToken) { result, error  in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.success = true

					self.currentBalances = result?.current ?? 0
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

									self.currentBalance()
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
}
