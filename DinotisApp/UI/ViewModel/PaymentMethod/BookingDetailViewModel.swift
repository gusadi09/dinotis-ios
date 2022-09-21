//
//  BookingDetailViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 08/10/21.
//

import Foundation
import SwiftKeychainWrapper

class DetailBookingViewModel: ObservableObject {
	static let shared = DetailBookingViewModel()

	let bookService = BookingMeetingService.shared
	private let refreshService = AuthService.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false

	let stateObservable = StateObservable.shared

	@Published var data: DetailBooking?

	@Published var isRefreshFailed = false

	@Published var statusCode = 0

	func getDetailBookings(id: String) {
		self.isLoading = true
		self.isError = false
		self.error = nil
		self.success = false
		self.isRefreshFailed = false

		bookService.bookingDetail(with: stateObservable.accessToken, id: id) { result, error in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.success = true

					self.data = result!
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

									self.getDetailBookings(id: id)
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
