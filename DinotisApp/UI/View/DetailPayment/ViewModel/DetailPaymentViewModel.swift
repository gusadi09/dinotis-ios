//
//  InvoiceViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 04/03/22.
//

import Foundation
import Combine
import OneSignal
import UIKit
import DinotisData

final class DetailPaymentViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	var backToChoosePayment: () -> Void
	
	private var stateObservable = StateObservable.shared
	private let deleteBookingsUseCase: DeleteBookingsUseCase

	private var cancellables = Set<AnyCancellable>()
	private let authRepository: AuthenticationRepository
	private let getBookingDetailUseCase: GetBookingDetailUseCase
    private let getInvoiceUseCase: GetInvoiceUseCase
	private let instructionLoader: PaymentInstructionLoader
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
	
	@Published var route: HomeRouting?
	
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?
	
	@Published var isRefreshFailed = false

	@Published var bookingData: UserBookingData?
	@Published var invoiceData: InvoiceResponse?
	@Published var bookingPayment: BookingPaymentData?
	
	@Published var bookingId: String
    @Published var subtotal: String
    @Published var extraFee: String
    @Published var serviceFee: String

	@Published var contentOffset: CGFloat = 0

	@Published var selected = false
    
    @Published var isCancelSheetShow = false
    @Published var isShowDetailPayment = false

	@Published var selectedTab = 0
	@Published var instruction: PaymentInstructionData?
	
	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		backToChoosePayment: @escaping () -> Void,
		bookingId: String,
        subtotal: String,
        extraFee: String,
        serviceFee: String,
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		getBookingDetailUseCase: GetBookingDetailUseCase = GetBookingDetailDefaultUseCase(),
		instructionLoader: PaymentInstructionLoader = PaymentInstructionLoader(),
        getInvoiceUseCase: GetInvoiceUseCase = GetInvoiceDefaultUseCase(),
		deleteBookingsUseCase: DeleteBookingsUseCase = DeleteBookingsDefaultUseCase()
	) {
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.backToChoosePayment = backToChoosePayment
		self.bookingId = bookingId
        self.subtotal = subtotal
        self.extraFee = extraFee
        self.serviceFee = serviceFee
		self.authRepository = authRepository
		self.getBookingDetailUseCase = getBookingDetailUseCase
		self.instructionLoader = instructionLoader
		self.getInvoiceUseCase = getInvoiceUseCase
		self.deleteBookingsUseCase = deleteBookingsUseCase
	}
	
	func routeToFinishInvoice(id: String) {
		let viewModel = InvoicesBookingViewModel(bookingId: id, backToRoot: self.backToRoot, backToHome: self.backToHome, backToChoosePayment: self.backToChoosePayment)
		
		DispatchQueue.main.async {[weak self] in
			self?.route = .bookingInvoice(viewModel: viewModel)
		}
	}

	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.isRefreshFailed = false
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
    
    func onGetInvoice(data: UserBookingData) {
        Task {
            await getInvoice()

            getInstruction(methodId: (data.bookingPayment?.paymentMethod?.id).orZero())
        }
    }

	func getBooking() async {
		onStartRequest()

		let result = await getBookingDetailUseCase.execute(by: bookingId)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.isLoading = false

				self?.bookingData = success
				self?.bookingPayment = success.bookingPayment

				if !(success.bookingPayment?.paymentMethod?.isQr ?? false || success.bookingPayment?.paymentMethod?.isEwallet ?? false) {
                    self?.onGetInvoice(data: success)
				}

				if success.bookingPayment?.paidAt != nil {
					self?.routeToFinishInvoice(id: (success.bookingPayment?.bookingID).orEmpty())
				}
			}
		case .failure(let failure):
			handleDefaultError(error: failure)
		}
	}

	func getInvoice() async {
		onStartRequest()
        
        let result = await getInvoiceUseCase.execute(by: bookingId)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.invoiceData = success
            }
        case .failure(_):
            break
        }
	}

	func onAppear() {
		Task {
			await getBooking()
		}
	}

	func refreshInvoice() {
		Task {
			await getBooking()
		}
	}

	func isNotQRandEwallet() -> Bool {
		!(self.bookingPayment?.paymentMethod?.isQr ?? false) && !(self.bookingPayment?.paymentMethod?.isEwallet ?? false)
	}

	func isEwallet() -> Bool {
		self.bookingPayment?.paymentMethod?.isEwallet ?? false
	}

	func isQR() -> Bool {
		self.bookingPayment?.paymentMethod?.isQr ?? false
	}

	func getInstruction(methodId: Int) {
		instructionLoader.paymentInstruction { result, error in
			if result != nil {
				DispatchQueue.main.async {
					for instructionItem in (result ?? []) where instructionItem.paymentMethod?.id == methodId {
						self.instruction = instructionItem
					}
				}

			} else {
				DispatchQueue.main.async {
					self.error = error?.message ?? ""
				}
			}
		}
	}

	func routeToRoot() {
		stateObservable.userType = 0
		stateObservable.isVerified = ""
		stateObservable.refreshToken = ""
		stateObservable.accessToken = ""
		stateObservable.isAnnounceShow = false
		OneSignal.setExternalUserId("")
		backToRoot()
	}

	func use(for scrollView: UIScrollView, onValueChanged: @escaping ((UIRefreshControl) -> Void)) {
		DispatchQueue.main.async {
			let refreshControl = UIRefreshControl()
			refreshControl.addTarget(
				self,
				action: #selector(self.onValueChangedAction),
				for: .valueChanged
			)
			scrollView.refreshControl = refreshControl
			self.onValueChanged = onValueChanged
		}

	}

	@objc private func onValueChangedAction(sender: UIRefreshControl) {
		Task.init {
			self.onValueChanged?(sender)
		}
	}

	func deleteBooking() async {
		onStartRequest()

		let result = await deleteBookingsUseCase.execute(by: bookingId)

		switch result {
		case .success(_):
			DispatchQueue.main.async { [weak self] in
				self?.isLoading = false
				self?.success = true

				self?.routeToFinishInvoice(id: (self?.bookingId).orEmpty())
			}
		case .failure(let failure):
			handleDefaultError(error: failure)
		}
	}

	func onDeleteBookings() {
		Task {
			await deleteBooking()
		}
	}
}
