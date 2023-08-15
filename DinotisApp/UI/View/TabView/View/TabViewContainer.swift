//
//  TabViewContainer.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/01/23.
//

import SwiftUI
import SwiftUINavigation
import DinotisDesignSystem
import DinotisData

struct TabViewContainer: View {

	@ObservedObject var viewModel: TabViewContainerViewModel
	@ObservedObject var state = StateObservable.shared

	var body: some View {
        if viewModel.isFromUserType {
            MainView(viewModel: viewModel, state: state)
        } else {
            NavigationView {
                MainView(viewModel: viewModel, state: state)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
        }
	}
    
    struct MainView: View {
        
        @ObservedObject var viewModel: TabViewContainerViewModel
        @ObservedObject var state: StateObservable
        
        @AppStorage("isShowTooltip") var isShowTooltip = false
        
        var body: some View {
            ZStack {
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.bookingInvoice,
                    destination: { viewModel in
                        UserInvoiceBookingView(
                            viewModel: viewModel.wrappedValue, mainTabValue: $viewModel.tab
                        )
                    },
                    onNavigate: {_ in},
                    label: {
                        EmptyView()
                    }
                )
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.detailPayment,
                    destination: {viewModel in
                        DetailPaymentView(
                            viewModel: viewModel.wrappedValue, mainTabValue: $viewModel.tab
                        )
                    },
                    onNavigate: {_ in},
                    label: {
                        EmptyView()
                    }
                )
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.userScheduleDetail,
                    destination: { viewModel in
                        UserScheduleDetail(
                            viewModel: viewModel.wrappedValue, mainTabValue: $viewModel.tab
                        )
                    },
                    onNavigate: {_ in},
                    label: {
                        EmptyView()
                    }
                )
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.talentProfileDetail
                ) { viewModel in
                    TalentProfileDetailView(viewModel: viewModel.wrappedValue, tabValue: $viewModel.tab)
                } onNavigate: { _ in
                    
                } label: {
                    EmptyView()
                }
                
                TabView(selection: $viewModel.tab) {
                    if viewModel.state.userType == 3 {
                        UserHomeView(homeVM: viewModel.userHomeVM, tabValue: $viewModel.tab)
                            .tag(TabRoute.explore)
                    } else {
                        UserHomeView(homeVM: viewModel.userHomeVM, tabValue: $viewModel.tab)
                            .tag(TabRoute.explore)
                    }
                    
                    SearchTalentView(viewModel: viewModel.searchVM, tabValue: $viewModel.tab)
                        .tag(TabRoute.search)
                    
                    ScheduleListView(viewModel: viewModel.scheduleVM, mainTabSelection: $viewModel.tab)
                        .onAppear {
                            self.isShowTooltip = false
                        }
                        .tag(TabRoute.agenda)
                    
                    if viewModel.state.userType == 2 {
                        TalentProfileView(viewModel: viewModel.profileVM)
                            .tag(TabRoute.profile)
                    } else if viewModel.state.userType == 3 {
                        UserProfileView(viewModel: viewModel.profileVM, tabValue: $viewModel.tab)
                            .tag(TabRoute.profile)
                    } else {
                        UserProfileView(viewModel: viewModel.profileVM, tabValue: $viewModel.tab)
                            .tag(TabRoute.profile)
                    }
                    
                }
                .dinotisTabStyle($viewModel.tab, isNewAgenda: $viewModel.hasNewAgenda, isShowTooltip: $isShowTooltip)
            }
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await viewModel.getCounter()
                }
                
                NotificationCenter.default.addObserver(forName: .audiencePaymentDetail, object: nil, queue: .main) { _ in
                    viewModel.routeToInvoice(id: state.bookId)
                }
                
                NotificationCenter.default.addObserver(forName: .creatorDetail, object: nil, queue: .main) { _ in
                    viewModel.routeToTalentDetail(username: state.usernameCreator)
                }
                
                NotificationCenter.default.addObserver(forName: .audienceBookingDetail, object: nil, queue: .main) { _ in
                    viewModel.routeToScheduleDetail()
                }
                
                NotificationCenter.default.addObserver(forName: .audienceInvoice, object: nil, queue: .main) { _ in
                    viewModel.routeToInvoice(id: state.bookId)
                }
                
                NotificationCenter.default.addObserver(forName: .audienceSuccesPayment, object: nil, queue: .main) { _ in
                    viewModel.routeToInvoiceBooking(id: state.bookId)
                }
                
                NotificationCenter.default.addObserver(forName: .audienceProfile, object: nil, queue: .main) { _ in
                    viewModel.route = nil
                    viewModel.tab = .profile
                }
            }
        }
    }
}

struct TabViewContainer_Previews: PreviewProvider {
	static var previews: some View {
		TabViewContainer(
			viewModel: TabViewContainerViewModel(
                isFromUserType: false,
                userHomeVM: UserHomeViewModel(),
				profileVM: ProfileViewModel(backToHome: {}),
                searchVM: SearchTalentViewModel(backToHome: {}),
                scheduleVM: ScheduleListViewModel(backToHome: {}, currentUserId: "")
			)
		)
	}
}
