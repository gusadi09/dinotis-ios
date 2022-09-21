//
//  BankAccountViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 27/10/21.
//

import Foundation
import SwiftKeychainWrapper

class BankAccountViewModel: ObservableObject {
	static let shared = BankAccountViewModel()

	let bankService = BankWithdrawService.shared
	private let refreshService = AuthService.shared
	@Published var isRefreshFailed = false

	let stateObservable = StateObservable.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var isSuccessGet: Bool = false
	@Published var isSuccessPost: Bool = false
	@Published var isSuccessPut: Bool = false
	@Published var error: HMError?

	@Published var data: BankAccResponse?

	@Published var dataHistory: HistoryTransaction?

	func getBankAcc() {
		self.isLoading = true
		self.isError = false
		self.isSuccessGet = false
		self.error = nil
		self.isRefreshFailed = false

		bankService.getBank(with: stateObservable.accessToken) { result, error  in
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

									self.getBankAcc()
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

	func addBankAcc(bankAcc: AddBankAccount) {
		self.isLoading = true
		self.isError = false
		self.isSuccessPost = false
		self.error = nil
		self.isRefreshFailed = false

		bankService.addBank(with: stateObservable.accessToken, by: bankAcc) { result, error  in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.isSuccessPost = true
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

									self.addBankAcc(bankAcc: bankAcc)
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

	func updateBankAcc(id: Int, by bankAcc: AddBankAccount) {
		self.isLoading = true
		self.isError = false
		self.isSuccessPut = false
		self.error = nil
		self.isRefreshFailed = false

		bankService.updateBank(with: stateObservable.accessToken, id: id, by: bankAcc) { result, error  in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.isSuccessPut = true
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

									self.updateBankAcc(id: id, by: bankAcc)
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

	func getHistory() {
		self.isLoading = true
		self.isError = false
		self.isSuccessGet = false
		self.error = nil
		self.isRefreshFailed = false

		bankService.getHistoryTransaction(with: stateObservable.accessToken) { result, error  in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.isSuccessGet = true

					self.dataHistory = result
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

									self.getHistory()
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
