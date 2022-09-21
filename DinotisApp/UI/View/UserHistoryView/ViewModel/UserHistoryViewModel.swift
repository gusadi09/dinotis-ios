//
//  UserHistoryViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 02/03/22.
//

import Foundation

final class UserHistoryViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	
	@Published var route: HomeRouting?

	@Published var bookingId = ""
	
	@Published var showMenuCard = false
	
	@Published var isLoading = false
	
	init(backToRoot: @escaping (() -> Void), backToHome: @escaping (() -> Void)) {
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		
	}

	func routeToScheduleDetail() {
		let viewModel = ScheduleDetailViewModel(bookingId: bookingId, backToRoot: self.backToRoot, backToHome: self.backToHome)

		DispatchQueue.main.async { [weak self] in
			self?.route = .userScheduleDetail(viewModel: viewModel)
		}
	}
}
