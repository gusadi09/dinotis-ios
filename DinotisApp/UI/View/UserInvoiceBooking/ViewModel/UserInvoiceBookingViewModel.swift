//
//  UserInvoiceBookingViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 04/03/22.
//

import Foundation
import Combine
import SwiftUI

final class InvoicesBookingViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	
	private var cancellables = Set<AnyCancellable>()
	
	private let bookingsRepository: BookingsRepository
	private let authRepository: AuthenticationRepository
	
	@Published var route: HomeRouting?
	
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: HMError?
	
	@Published var bookingData: UserBooking?
	
	@Published var isRefreshFailed = false
	
	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		bookingsRepository: BookingsRepository = BookingsDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
	) {
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.bookingsRepository = bookingsRepository
		self.authRepository = authRepository
	}
	
	func onStartFetch() {
		withAnimation {
			self.isLoading = true
		}

		self.isError = false
		self.success = false
		self.error = nil
	}
	
	func getBookingById(bookingId: String) {
		onStartFetch()
		
		bookingsRepository
			.provideGetBookingsById(bookingId: bookingId)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {self?.getBookingById(bookingId: bookingId)})
						} else {
							self?.isError = true

							withAnimation {
								self?.isLoading = false
							}
							
							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}
					
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						withAnimation {
							self?.isLoading = false
						}
					}
				}
			} receiveValue: { value in
				self.bookingData = value
			}
			.store(in: &cancellables)
	}
	
	func onStartRefresh() {
		self.isRefreshFailed = false
		withAnimation {
			self.isLoading = true
		}

		self.success = false
		self.error = nil
	}
	
	func refreshToken(onComplete: @escaping (() -> Void)) {
		onStartRefresh()
		
		let refreshToken = authRepository.loadFromKeychain(forKey: KeychainKey.refreshToken)
		
		authRepository
			.refreshToken(with: refreshToken)
			.sink { result in
				switch result {
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						withAnimation {
							self?.isLoading = false
						}
						onComplete()
					}
					
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						self?.isRefreshFailed = true
						withAnimation {
							self?.isLoading = false
						}
						self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
					}
				}
			} receiveValue: { value in
				self.stateObservable.refreshToken = value.refreshToken
				self.stateObservable.accessToken = value.accessToken
			}
			.store(in: &cancellables)
		
	}
}
