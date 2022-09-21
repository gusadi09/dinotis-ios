//
//  ChangeEmailViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 27/09/21.
//

import Foundation
import SwiftKeychainWrapper

class ChangeEmailViewModel: ObservableObject {
    static let shared = ChangeEmailViewModel()
    
    let authService = AuthService.shared

    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var error: HMError?
    @Published var success: Bool = false
    
    @Published var statusCode = 0

	let stateObservable = StateObservable.shared

	@Published var isRefreshFailed = false
    
    init() {
        
    }
    
    func changeEmail(params: ResendOtp) {
        self.isLoading = true
        self.isError = false
		self.success = false
        self.error = nil
		self.isRefreshFailed = false
        
		authService.changeEmail(token: stateObservable.accessToken, params: params) { result, error in
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

									self.changeEmail(params: params)
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
