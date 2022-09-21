//
//  TrendingViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/10/21.
//

import Foundation
import SwiftKeychainWrapper

class TrendingViewModel: ObservableObject {
	static let shared = TrendingViewModel()

	let trendService = TrendingService.shared
	private let refreshService = AuthService.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var isSuccessGet: Bool = false

	@Published var data: TrendingData?

	let stateObservable = StateObservable.shared

	@Published var isRefreshFailed = false

	@Published var statusCode = 0

	func getTrendingTalent() {
		self.isLoading = true
		self.statusCode = 0
		self.isError = false
		self.isSuccessGet = false
		self.isRefreshFailed = false

		trendService.getTrending(with: stateObservable.accessToken) { result, error in
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
									KeychainWrapper.standard.set(response.accessToken, forKey: "auth.accessToken")
									self.stateObservable.accessToken = response.accessToken
									self.stateObservable.refreshToken = response.refreshToken

									self.getTrendingTalent()
							}
						}
					} else {
						DispatchQueue.main.async {
							self.isLoading = false
							self.isError = true
							self.isSuccessGet = false
							self.statusCode = error.statusCode ?? 0

							self.error = HMError.serverError(code: error.statusCode ?? 0, message: error.message ?? "")
						}
					}
				}
			}
		}
	}
}
