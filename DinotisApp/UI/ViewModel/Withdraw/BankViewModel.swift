//
//  BankViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 27/10/21.
//

import Foundation
import SwiftKeychainWrapper

class BankViewModel: ObservableObject {
	static let shared = BankViewModel()

	let miscService = MiscService.shared
	private let refreshService = AuthService.shared

	let stateObservable = StateObservable.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var isSuccessGet: Bool = false
	@Published var isSuccessPost: Bool = false
	@Published var error: HMError?

	@Published var isRefreshFailed = false

	@Published var data: BankResponse?

	func getBank() {
		self.isLoading = true
		self.isError = false
		self.isSuccessGet = false
		self.error = nil
		self.isRefreshFailed = false

		miscService.getBankWithdraw(token: stateObservable.accessToken) { result, error  in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.isSuccessGet = true

					self.data = result
				}
			} else {
				if let error = error {
					if error.statusCode == 401 {
						self.refreshService.refreshToken(with: self.stateObservable.refreshToken) { response in
							switch response {
								case .failure(_):
									DispatchQueue.main.async {
										self.isLoading = false
										self.isRefreshFailed = true
									}
								case .success(let response):
									self.stateObservable.accessToken = response.accessToken
									self.stateObservable.refreshToken = response.refreshToken

									self.getBank()
							}
						}
					} else {
						DispatchQueue.main.async {
							self.isLoading = false
							self.isError = true

							self.error = HMError.serverError(code: error.statusCode ?? 0, message: error.message ?? "")
						}
					}
				}
			}
		}
	}
}
