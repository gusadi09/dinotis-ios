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

	var backToRoot: () -> Void
    
    private let counterUseCase: GetCounterUseCase

	@Published var userHomeVM: UserHomeViewModel
	@Published var talentHomeVM: TalentHomeViewModel
	@Published var profileVM: ProfileViewModel
	@Published var searchVM: SearchTalentViewModel
    @Published var scheduleVM: ScheduleListViewModel

	@Published var state = StateObservable.shared
	@Published var tab: TabRoute = .explore
	@Published var hasNewAgenda = false

	@Published var route: HomeRouting?

	init(
        userHomeVM: UserHomeViewModel,
        talentHomeVM: TalentHomeViewModel,
        profileVM: ProfileViewModel,
        searchVM: SearchTalentViewModel,
        scheduleVM: ScheduleListViewModel,
        backToRoot: @escaping () -> Void,
        counterUseCase: GetCounterUseCase = GetCounterDefaultUseCase()
    ) {
		self.userHomeVM = userHomeVM
		self.talentHomeVM = talentHomeVM
		self.profileVM = profileVM
		self.searchVM = searchVM
		self.backToRoot = backToRoot
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
            backToRoot: self.backToRoot,
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
        let viewModel = TalentProfileDetailViewModel(backToRoot: self.backToRoot, backToHome: { self.route = nil }, username: username)

        DispatchQueue.main.async { [weak self] in
            self?.route = .talentProfileDetail(viewModel: viewModel)
        }
    }
    
    func routeToScheduleDetail() {
        let viewModel = ScheduleDetailViewModel(isActiveBooking: true, bookingId: state.bookId, backToRoot: self.backToRoot, backToHome: { self.route = nil }, isDirectToHome: true)

        DispatchQueue.main.async { [weak self] in
            self?.route = .userScheduleDetail(viewModel: viewModel)
        }
    }
    
    func routeToInvoiceBooking(id: String) {
        let viewModel = InvoicesBookingViewModel(bookingId: id, backToRoot: self.backToRoot, backToHome: {self.route = nil}, backToChoosePayment: {self.route = nil})
        
        DispatchQueue.main.async {[weak self] in
            self?.route = .bookingInvoice(viewModel: viewModel)
        }
    }
}
