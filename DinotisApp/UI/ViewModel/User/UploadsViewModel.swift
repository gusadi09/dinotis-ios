//
//  UploadsViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 27/09/21.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

class UploadsViewModel: ObservableObject {
    static let shared = UploadsViewModel()
    
    let uploadService = UploadService.shared
	private let refreshService = AuthService.shared

    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var error: HMError?
    @Published var success: Bool = false
    
    @Published var data: UploadResponse?
    
    @Published var statusCode = 0

	let stateObservable = StateObservable.shared

	@Published var isRefreshFailed = false
    
    init() {
        
    }
    
    func uploadSingle(image: UIImage) {
        self.isLoading = true
        self.isError = false
        self.error = nil
        self.success = false
		self.isRefreshFailed = false
        
        uploadService.uploadSingle(image: image) { result, error in
            if result != nil {
                self.isLoading = false
                self.success = true
                
                self.data = result
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

									self.uploadSingle(image: image)
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
