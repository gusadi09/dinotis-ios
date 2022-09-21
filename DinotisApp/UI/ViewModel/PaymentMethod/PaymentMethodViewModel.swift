//
//  PaymentMethodViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/10/21.
//

import Foundation
import Combine
import SwiftKeychainWrapper

class PaymentMethodViewModel: ObservableObject {
	static let shared = PaymentMethodViewModel()

	let miscService = MiscService.shared
	private let refreshService = AuthService.shared

	let stateObservable = StateObservable.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false

	@Published var data: PaymentData = []

	@Published var extraFee = 0

	@Published var isRefreshFailed = false

	func getPayment() {
		self.isLoading = true
		self.isError = false
		self.error = nil
		self.isRefreshFailed = false

		miscService.getPaymentMethod { result, error in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.success = true

					self.data = result ?? []

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

									self.getPayment()
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

	func getExtraFee(meetingId: String, price: String) {
		self.isLoading = true
		self.isError = false
		self.error = nil
		self.isRefreshFailed = false

		miscService.extraFee(token: stateObservable.accessToken, meetingId: meetingId) { result, error in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.success = true

					self.extraFee = result?.extraFee ?? 0

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

									self.getPayment()
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
