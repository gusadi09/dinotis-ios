//
//  ProfessionViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 25/09/21.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper

class ProfessionViewModel: ObservableObject {
	static let shared = ProfessionViewModel()

	let miscService = MiscService.shared
	private let refreshService = AuthService.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false

	@Published var data: ProfessionResponse?

	let stateObservable = StateObservable.shared

	let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "https://dev.api.dinotis.com/api/v1")

	@Published var isRefreshFailed = false

	func getProfession() {
		self.isLoading = true
		self.isError = false
		self.error = nil
		self.isRefreshFailed = false

		miscService.getProfession(token: stateObservable.accessToken) { result, error in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false

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

									self.getProfession()
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
