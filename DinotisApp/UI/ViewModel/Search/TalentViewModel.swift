//
//  TalentViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/10/21.
//

import Foundation
import SwiftKeychainWrapper

class TalentViewModel: ObservableObject {
    static let shared = TalentViewModel()
    
    let searchService = SearchingService.shared
	private let refreshService = AuthService.shared

    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var error: HMError?
    @Published var success: Bool = false

	let stateObservable = StateObservable.shared

    @Published var data: TalentFromSearch?

	@Published var isRefreshFailed = false

    init() {
        
    }
    
    func getTalentFromSearch(by username: String) {
        self.isLoading = true
        self.isError = false
        self.error = nil
		self.success = false
		self.isRefreshFailed = false
        
        searchService.getTalentFromSearch(with: username) { result, error in
            if result != nil {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.success = true
                    
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

									self.getTalentFromSearch(by: username)
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
