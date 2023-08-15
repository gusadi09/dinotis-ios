//
//  TabViewContainerViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/01/23.
//

import Foundation
import DinotisDesignSystem
import DinotisData

final class TabViewContainerViewModel: ObservableObject {
    
    private let counterUseCase: GetCounterUseCase

    @Published var isFromUserType: Bool
	@Published var userHomeVM: UserHomeViewModel
	@Published var profileVM: ProfileViewModel
	@Published var searchVM: SearchTalentViewModel
    @Published var scheduleVM: ScheduleListViewModel

	@Published var state = StateObservable.shared
	@Published var tab: TabRoute = .explore
	@Published var hasNewAgenda = false

	@Published var route: HomeRouting?

	init(
        isFromUserType: Bool,
        userHomeVM: UserHomeViewModel,
        profileVM: ProfileViewModel,
        searchVM: SearchTalentViewModel,
        scheduleVM: ScheduleListViewModel,
        counterUseCase: GetCounterUseCase = GetCounterDefaultUseCase()
    ) {
        self.isFromUserType = isFromUserType
		self.userHomeVM = userHomeVM
		self.profileVM = profileVM
		self.searchVM = searchVM
        self.scheduleVM = scheduleVM
        self.counterUseCase = counterUseCase
	}
    
    func getCounter() async {
        let result = await counterUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.hasNewAgenda = success.todayAgendaCount.orZero() > 0
            }
        case .failure(_):
            break
        }
    }
    
    func routeToInvoice(id: String) {
        let viewModel = DetailPaymentViewModel(
            backToHome: {self.route = nil},
            backToChoosePayment: {self.route = nil},
            bookingId: id,
            subtotal: "",
            extraFee: "",
            serviceFee: ""
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .detailPayment(viewModel: viewModel)
        }
    }
    
    func routeToTalentDetail(username: String) {
        let viewModel = TalentProfileDetailViewModel(backToHome: { self.route = nil }, username: username)

        DispatchQueue.main.async { [weak self] in
            self?.route = .talentProfileDetail(viewModel: viewModel)
        }
    }
    
    func routeToScheduleDetail() {
        let viewModel = ScheduleDetailViewModel(isActiveBooking: true, bookingId: state.bookId, backToHome: { self.route = nil }, isDirectToHome: true)

        DispatchQueue.main.async { [weak self] in
            self?.route = .userScheduleDetail(viewModel: viewModel)
        }
    }
    
    func routeToInvoiceBooking(id: String) {
        let viewModel = InvoicesBookingViewModel(bookingId: id, backToHome: {self.route = nil}, backToChoosePayment: {self.route = nil})
        
        DispatchQueue.main.async {[weak self] in
            self?.route = .bookingInvoice(viewModel: viewModel)
        }
    }
}
