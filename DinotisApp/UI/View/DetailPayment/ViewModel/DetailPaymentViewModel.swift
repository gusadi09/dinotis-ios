//
//  InvoiceViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 04/03/22.
//

import Foundation

final class DetailPaymentViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	
	@Published var route: HomeRouting?
	
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: HMError?
	
	@Published var isRefreshFailed = false
	
	@Published var methodName: String
	@Published var methodIcon: String
	@Published var redirectUrl: String?
	@Published var qrCodeUrl: String?
	@Published var bookingId: String
	@Published var isQR: Bool
	@Published var isEwallet: Bool
	
	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		methodName: String,
		methodIcon: String,
		redirectUrl: String?,
		qrCodeUrl: String?,
		bookingId: String,
		isQR: Bool,
		isEwallet: Bool
	) {
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.methodName = methodName
		self.methodIcon = methodIcon
		self.redirectUrl = redirectUrl
		self.qrCodeUrl = qrCodeUrl
		self.bookingId = bookingId
		self.isQR = isQR
		self.isEwallet = isEwallet
	}
	
	func routeToFinishInvoice() {
		let viewModel = InvoicesBookingViewModel(backToRoot: self.backToRoot, backToHome: self.backToRoot)
		
		DispatchQueue.main.async {[weak self] in
			self?.route = .bookingInvoice(viewModel: viewModel)
		}
	}
}
