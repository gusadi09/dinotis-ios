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

	init(backToRoot: @escaping (() -> Void), backToHome: @escaping (() -> Void)) {
		self.backToRoot = backToRoot
		self.backToHome = backToHome

	}

	func routeToFinishInvoice() {
		let viewModel = InvoicesBookingViewModel(backToRoot: self.backToRoot, backToHome: self.backToRoot)

		DispatchQueue.main.async {[weak self] in
			self?.route = .bookingInvoice(viewModel: viewModel)
		}
	}
}
