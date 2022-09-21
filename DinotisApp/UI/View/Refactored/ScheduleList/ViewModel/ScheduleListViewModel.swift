//
//  ScheduleListViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/03/22.
//

import Foundation
import UIKit

final class ScheduleListViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	@Published var currentUserId: String
	
	@Published var route: HomeRouting?
	
	@Published var paymentName = ""
	
	@Published var showMenuCard = false
	
	@Published var username = ""
	
	@Published var meetingID = ""
	
	@Published var bookingID = ""
	@Published var invoicePrice = 0
	@Published var methodId = 0
	@Published var methodName = ""
	@Published var methodIcon = ""
	
	@Published var contentOffset = CGFloat.zero
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: HMError?
	
	@Published var price = ""
	@Published var meetingId = ""
	
	@Published var redirectUrl: String?
	@Published var qrCodeUrl: String?
	
	@Published var isQr = false
	@Published var isEwallet = false
	
	@Published var isRefreshFailed = false
	
	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		currentUserId: String
	) {
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.currentUserId = currentUserId
	}
	
	func routeToSearch() {
		let viewModel = SearchTalentViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome)
		
		DispatchQueue.main.async {[weak self] in
			self?.route = .searchTalent(viewModel: viewModel)
		}
	}
	
	func routeToInvoiceBooking() {
		let viewModel = InvoicesBookingViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome)
		
		DispatchQueue.main.async {[weak self] in
			self?.route = .bookingInvoice(viewModel: viewModel)
		}
	}
	
	func routeToTalentProfile() {
		let viewModel = TalentProfileDetailViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome, username: self.username)
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .talentProfileDetail(viewModel: viewModel)
		}
	}
	
	func routeToUsertDetailSchedule() {
		let viewModel = ScheduleDetailViewModel(bookingId: meetingID, backToRoot: self.backToRoot, backToHome: self.backToHome)
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .userScheduleDetail(viewModel: viewModel)
		}
	}
	
	func routeToInvoice() {
		let viewModel = DetailPaymentViewModel(
			backToRoot: self.backToRoot,
			backToHome: self.backToHome,
			methodName: methodName,
			methodIcon: methodIcon,
			redirectUrl: self.redirectUrl,
			qrCodeUrl: self.qrCodeUrl,
			bookingId: self.bookingID,
			isQR: self.isQr,
			isEwallet: self.isEwallet
		)
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .detailPayment(viewModel: viewModel)
		}
	}
	
	func routeToUserHistory() {
		let viewModel = UserHistoryViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome)
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .historyList(viewModel: viewModel)
		}
	}
	
	func routeToPayment(price: String) {
		let viewModel = PaymentMethodsViewModel(price: price, meetingId: meetingId, backToRoot: self.backToRoot, backToHome: self.backToHome)
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .paymentMethod(viewModel: viewModel)
		}
	}
}
