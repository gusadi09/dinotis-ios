//
//  AddMeetingViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 23/10/21.
//

import Foundation
import SwiftKeychainWrapper

class AddMeetingViewModel: ObservableObject {
	static let shared = AddMeetingViewModel()

	let bookService = BookingMeetingService.shared
	private let refreshService = AuthService.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false

	let stateObservable = StateObservable.shared

	@Published var data: String?

	@Published var statusCode = 0

	@Published var isRefreshFailed = false

	func addMeeting(meeting: MeetingForm) {
		self.isLoading = true
		self.isError = false
		self.error = nil
		self.success = false
		self.isRefreshFailed = false

		bookService.addMeeting(with: stateObservable.accessToken, meeting: meeting) { result, error in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.success = true

					self.data = result.orEmpty()
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

									self.addMeeting(meeting: meeting)
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
