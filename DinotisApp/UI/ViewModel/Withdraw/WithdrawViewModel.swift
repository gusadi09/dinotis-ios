//
//  WithdrawViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/10/21.
//

import Foundation
import SwiftKeychainWrapper

class WithdrawViewModel: ObservableObject {
	static let shared = WithdrawViewModel()

	let bankService = BankWithdrawService.shared
	private let refreshService = AuthService.shared

	let stateObservable = StateObservable.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var isSuccessPost: Bool = false
	@Published var isSuccessGet: Bool = false
	@Published var error: HMError?
	@Published var statusCode = 0

	@Published var isRefreshFailed = false

	@Published var dataDetail: WithdrawDetailResponse?

	func withdraw(params: WithdrawParams) {
		self.isLoading = true
		self.isError = false
		self.isSuccessPost = false
		self.error = nil
		self.statusCode = 0
		self.isRefreshFailed = false

		bankService.withdrawSaldo(with: stateObservable.accessToken, by: params) { result, error  in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.isSuccessPost = true
					self.statusCode = 201
				}
			} else {
				if let error = error {
					if error.statusCode == 401 {
						self.refreshService.refreshToken(with: self.stateObservable.refreshToken) { response in
							switch response {
								case .failure(let error):
									DispatchQueue.main.async {
										self.isLoading = false
										self.isRefreshFailed = true
										self.statusCode = error.responseCode ?? 0
									}
								case .success(let response):
									self.stateObservable.accessToken = response.accessToken
									self.stateObservable.refreshToken = response.refreshToken

									self.withdraw(params: params)
							}
						}
					} else {
						DispatchQueue.main.async {
							self.isLoading = false
							self.isError = true
							self.statusCode = error.statusCode ?? 0

							self.error = HMError.serverError(code: error.statusCode ?? 0, message: error.message ?? "")
						}
					}
				}
			}
		}
	}

	func withdrawDetail(withdrawId: String) {
		self.isLoading = true
		self.isError = false
		self.isSuccessGet = false
		self.error = nil
		self.statusCode = 0
		self.isRefreshFailed = false

		bankService.getDetailWithdraw(with: stateObservable.accessToken, withdrawId: withdrawId) { result, error  in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.isSuccessGet = true
					self.statusCode = 200

					self.dataDetail = result
				}
			} else {
				if let error = error {
					if error.statusCode == 401 {
						self.refreshService.refreshToken(with: self.stateObservable.refreshToken) { response in
							switch response {
								case .failure(let error):
									DispatchQueue.main.async {
										self.isLoading = false
										self.isRefreshFailed = true
										self.statusCode = error.responseCode ?? 0
									}
								case .success(let response):
									self.stateObservable.accessToken = response.accessToken
									self.stateObservable.refreshToken = response.refreshToken

									self.withdrawDetail(withdrawId: withdrawId)
							}
						}
					} else {
						DispatchQueue.main.async {
							self.isLoading = false
							self.isError = true
							self.statusCode = error.statusCode ?? 0

							self.error = HMError.serverError(code: error.statusCode ?? 0, message: error.message ?? "")
						}
					}
				}
			}
		}
	}
}
