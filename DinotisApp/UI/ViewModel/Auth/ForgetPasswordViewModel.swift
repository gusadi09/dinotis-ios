//
//  ForgetPasswordViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/09/21.
//

import Foundation

class ForgetPasswordViewModel: ObservableObject {
    static let shared = ForgetPasswordViewModel()
    
    let authService = AuthService.shared

    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var error: HMError?
    @Published var success: Bool = false

	@Published var isRefreshFailed = false
    
    init() {
        
    }
    
    func forgetPassword(email: ResendOtp) {
        self.isLoading = true
        self.isError = false
        self.error = nil
        
        authService.forgetPassword(params: email) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.success = true
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
