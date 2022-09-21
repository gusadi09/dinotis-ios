//
//  BookingPayViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/10/21.
//

import Foundation
import SwiftKeychainWrapper

class BookingPayViewModel: ObservableObject {
	static let shared = BookingPayViewModel()

	let payService = PaymentService.shared
	private let refreshService = AuthService.shared

	let stateObservable = StateObservable.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false
	@Published var isSuccessFree = false

	@Published var statusCode = 0

	@Published var data: BookingData?

	@Published var isRefreshFailed = false

	func bookingPay(by method: BookingPay) {
		self.isLoading = true
		self.isError = false
		self.error = nil
		self.isRefreshFailed = false
		self.success = false
		self.isSuccessFree = false

		payService.bookingPay(with: stateObservable.accessToken, by: method) { result, error in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false

					if method.paymentMethod == 99 {
						self.isSuccessFree = true
					} else {
						self.success = true
					}

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

									self.bookingPay(by: method)
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
