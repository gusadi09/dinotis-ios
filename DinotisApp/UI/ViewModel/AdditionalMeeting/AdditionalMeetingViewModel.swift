//
//  AdditionalMeetingViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/10/21.
//

import Foundation
import SwiftKeychainWrapper

class AdditionalMeetingViewModel: ObservableObject {
	static let shared = AdditionalMeetingViewModel()

	let bookService = BookingMeetingService.shared
	private let refreshService = AuthService.shared

	let stateObservable = StateObservable.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var isSuccessEnd: Bool = false
	@Published var isSuccessEdit: Bool = false
	@Published var isSuccessDelete: Bool = false

	@Published var isRefreshFailed = false

	@Published var statusCode = 0

	func endMeeting(meetingId: String) {
		self.isLoading = true
		self.isError = false
		self.error = nil
		self.isSuccessEnd = false
		self.isRefreshFailed = false

		bookService.endMeeting(with: stateObservable.accessToken, id: meetingId) { result, error in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.isSuccessEnd = true
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

									self.endMeeting(meetingId: meetingId)
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

	func editMeeting(meetingId: String, form: MeetingForm) {
		self.isLoading = true
		self.isError = false
		self.error = nil
		self.isSuccessEdit = false
		self.isRefreshFailed = false

		bookService.editMeeting(with: stateObservable.accessToken, meeting: form, meetingId: meetingId) { result, error in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.isSuccessEdit = true
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

									self.editMeeting(meetingId: meetingId, form: form)
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

	func deleteMeeting(meetingId: String) {
		self.isLoading = true
		self.isError = false
		self.error = nil
		self.isSuccessDelete = false
		self.isRefreshFailed = false

		bookService.deleteMeeting(with: stateObservable.accessToken, meetingId: meetingId) { result, error in
			if result != nil {
				DispatchQueue.main.async {
					self.isLoading = false
					self.isSuccessDelete = true
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

									self.deleteMeeting(meetingId: meetingId)
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
