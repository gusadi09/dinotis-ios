//
//  RefreshViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/09/21.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper
import SwiftUI

class RefreshViewModel: ObservableObject {
	static let shared = RefreshViewModel()

	let authService = AuthService.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false

	@ObservedObject var stateObservable = StateObservable.shared

	func refresh(with refreshToken: String) {
		self.isLoading = true
		self.isError = false
		self.error = nil

		authService.refreshToken(with: refreshToken) { result in
			switch result {
				case .success(let response):
					DispatchQueue.main.async {
						self.isLoading = false

						self.stateObservable.accessToken = response.accessToken
						self.stateObservable.refreshToken = response.refreshToken

					}
				case .failure(let error):
					DispatchQueue.main.async {
						self.isLoading = false
						self.isError = true
						self.success = false

						self.error = HMError.serverError(code: error.asAFError?.responseCode ?? -1, message: error.localizedDescription)
					}
			}
		}
	}
}
