//
//  StartMeetViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 12/10/21.
//

import Foundation
import SwiftKeychainWrapper

class StartMeetViewModel: ObservableObject {
	static let shared = StartMeetViewModel()

	let agoraService = AgoraService.shared
	private let refreshService = AuthService.shared

	@Published var isLoading: Bool = false
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false

	let stateObservable = StateObservable.shared

	@Published var data: StartMeetingResponse?

	@Published var isRefreshFailed = false

	@Published var statusCode = 0

	func startMeet(by meetingId: String) {
		self.isLoading = true
		self.isError = false
		self.error = nil
		self.isRefreshFailed = false

		agoraService.startMeeting(with: stateObservable.accessToken, id: meetingId) { result, error in
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

									self.startMeet(by: meetingId)
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
