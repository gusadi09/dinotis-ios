//
//  UpdateViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/10/21.
//

import Foundation
import SwiftKeychainWrapper

class UpdateViewModel: ObservableObject {
	static let shared = UpdateViewModel()

	let authService = AuthService.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var success: Bool = false
	@Published var error: HMError?

	@Published var data: Users?

	let stateObservable = StateObservable.shared

	@Published var isRefreshFailed = false

	@Published var toHome = false

	func updateUsers(with userProfile: UpdateUser) {
		self.isLoading = true
		self.isError = false
		self.error = nil
		self.toHome = false
		self.isRefreshFailed = false

		authService.updateUser(token: stateObservable.accessToken, with: userProfile) { result, error  in

			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.toHome = true
					self.success = true

					self.data = result
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

									self.updateUsers(with: userProfile)
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
