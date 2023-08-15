//
//  UserInvoiceBookingViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 04/03/22.
//

import Foundation
import Combine
import SwiftUI
import DinotisData

final class InvoicesBookingViewModel: ObservableObject {
	
	var backToHome: () -> Void
	var backToChoosePayment: () -> Void
	
	private var stateObservable = StateObservable.shared
	
	private var cancellables = Set<AnyCancellable>()
	
	private let getBookingDetailUseCase: GetBookingDetailUseCase
	private let authRepository: AuthenticationRepository

	@Published var bookingId: String
	
	@Published var route: HomeRouting?
	
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?
	
	@Published var bookingData: UserBookingData?
	
	@Published var isRefreshFailed = false
	
	init(
		bookingId: String,
		backToHome: @escaping (() -> Void),
		backToChoosePayment: @escaping () -> Void,
		getBookingDetailUseCase: GetBookingDetailUseCase = GetBookingDetailDefaultUseCase(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
	) {
		self.bookingId = bookingId
		self.backToHome = backToHome
		self.backToChoosePayment = backToChoosePayment
		self.getBookingDetailUseCase = getBookingDetailUseCase
		self.authRepository = authRepository
	}
	
	func onStartFetch() {
		DispatchQueue.main.async { [weak self] in
			withAnimation {
				self?.isLoading = true
			}

			self?.isError = false
			self?.success = false
			self?.error = nil
		}

	}

	func handleDefaultError(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoading = false

			if let error = error as? ErrorResponse {
				self?.error = error.message.orEmpty()

				if error.statusCode.orZero() == 401 {
					self?.isRefreshFailed.toggle()
				} else {
					self?.isError = true
				}
			} else {
				self?.isError = true
				self?.error = error.localizedDescription
			}

		}
	}
	
	func getBookingById() async {
		onStartFetch()

		let result = await getBookingDetailUseCase.execute(by: self.bookingId)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.success = true
				withAnimation {
					self?.isLoading = false
				}

				self?.bookingData = success
			}
		case .failure(let failure):
			handleDefaultError(error: failure)
		}

	}
	
	func onStartRefresh() {
		DispatchQueue.main.async { [weak self] in
			self?.isRefreshFailed = false
			withAnimation {
				self?.isLoading = true
			}

			self?.success = false
			self?.error = nil
		}

	}

	func onGetBookingDetail() {
		Task {
			await getBookingById()
		}
	}
    
    func routeToDetailSchedule() {
        let viewModel = ScheduleDetailViewModel(isActiveBooking: true, bookingId: (bookingData?.id).orEmpty(), backToHome: self.backToHome, isDirectToHome: true)
        
        DispatchQueue.main.async {[weak self] in
            self?.route = .userScheduleDetail(viewModel: viewModel)
        }
    }
}
