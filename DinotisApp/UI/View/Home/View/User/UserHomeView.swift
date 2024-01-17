//
//  UserHomeView.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/08/21.
//

import Introspect
import DinotisData
import DinotisDesignSystem
import QGrid
import SwiftUI

struct UserHomeView: View {
    
    @EnvironmentObject var homeVM: UserHomeViewModel
    @ObservedObject var state = StateObservable.shared
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @AppStorage("isShowTooltip") var isShowTooltip = false
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    @Binding var tabValue: TabRoute
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                NavigationHelper(tabValue: $tabValue)
                    .environmentObject(homeVM)
                
                ZStack(alignment: .center) {
                    
                    Color.DinotisDefault.baseBackground.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        
                        HeaderView()
                            .environmentObject(homeVM)
                            .onChange(of: state.isGoToDetailSchedule) { value in
                                if value {
                                    homeVM.routeToScheduleList()
                                }
                            }
                        
                        TabView(selection: $homeVM.currentMainTab,
                                content:  {
                            ForYouContent(tabValue: $tabValue, geo: geo)
                                .environmentObject(homeVM)
                                .tag(AudienceHomeTab.forYou)
                            
                            FollowingContent(geo: geo)
                                .environmentObject(homeVM)
                                .tag(AudienceHomeTab.following)
                        })
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .ignoresSafeArea()
                    }
                    
                    if !homeVM.announceData.isEmpty {
                        AnnouncementView(
                            items: $homeVM.announceData[homeVM.announceIndex],
                            action: {
                                if homeVM.announceData.last?.id == homeVM.announceData[homeVM.announceIndex].id {
                                    state.isAnnounceShow = true
                                } else {
                                    homeVM.announceIndex += 1
                                }
                            }
                        )
                    }
                }
                .dinotisAlert(
                    isPresent: $homeVM.isShowAlert,
                    title: homeVM.alert.title,
                    isError: homeVM.alert.isError,
                    message: homeVM.alert.message,
                    primaryButton: homeVM.alert.primaryButton,
                    secondaryButton: homeVM.alert.secondaryButton
                )
                .navigationBarTitle(Text(""))
                .navigationBarHidden(true)
                
                if state.isShowTooltip {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                state.isShowTooltip = false
                                isShowTooltip = false
                            }
                            
                        }
                }
                    
            }
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
            .onAppear {
                if homeVM.sessionContent.isEmpty {
                    homeVM.onScreenAppear(geo: geo)
                }
                
                AppDelegate.orientationLock = .portrait
                
                if isFirstLaunch {
                    withAnimation {
                        self.state.isShowTooltip = true
                        self.isShowTooltip = true
                        self.isFirstLaunch = false
                    }
                }
            }
        }
        .sheet(
            isPresented: $homeVM.isShowSessionDetail,
            content: {
                if #available(iOS 16.0, *) {
                    SessionDetailView(viewModel: homeVM)
                        .presentationDetents([.fraction(0.8), .large])
                        .dynamicTypeSize(.large)
                } else {
                    SessionDetailView(viewModel: homeVM)
                        .dynamicTypeSize(.large)
                }
            }
        )
        .sheet(
            isPresented: $homeVM.isShowPaymentOption,
            content: {
                if #available(iOS 16.0, *) {
                    PaymentTypeOption(viewModel: homeVM)
                    .presentationDetents([.fraction(homeVM.sessionCard.isPrivate.orFalse() ? 0.44 : 0.33)])
                    .dynamicTypeSize(.large)
                } else {
                    PaymentTypeOption(viewModel: homeVM)
                        .dynamicTypeSize(.large)
                }
            }
        )
        .sheet(
            isPresented: $homeVM.isShowCoinPayment,
            onDismiss: {
                homeVM.resetStateCode()
            },
            content: {
                if #available(iOS 16.0, *) {
                    CoinPaymentSheetView(viewModel: homeVM)
                        .presentationDetents([.fraction(0.85), .large])
                        .dynamicTypeSize(.large)
                } else {
                    CoinPaymentSheetView(viewModel: homeVM)
                        .dynamicTypeSize(.large)
                }
            }
        )
        .sheet(
            isPresented: $homeVM.isShowAddCoin,
            content: {
                if #available(iOS 16.0, *) {
                    AddCoinSheetView(viewModel: homeVM)
                        .presentationDetents([.fraction(0.67), .large])
                        .dynamicTypeSize(.large)
                } else {
                    AddCoinSheetView(viewModel: homeVM)
                        .dynamicTypeSize(.large)
                }
            }
        )
        .sheet(isPresented: $homeVM.isShowCollabList, content: {
            if #available(iOS 16.0, *) {
              SelectedCollabCreatorView(
                isEdit: false,
                isAudience: true,
                arrUsername: .constant((homeVM.sessionCard.meetingCollaborations ?? []).compactMap({
                  $0.username
              })),
                arrTalent: .constant(homeVM.sessionCard.meetingCollaborations ?? [])) {
                    homeVM.isShowCollabList = false
                } visitProfile: { item in
                    homeVM.isShowSessionDetail = false
                    homeVM.username = item
                    homeVM.routeToTalentProfile()
                }
                .presentationDetents([.medium, .large])
                .dynamicTypeSize(.large)
            } else {
              SelectedCollabCreatorView(
                isEdit: false,
                isAudience: true,
                arrUsername: .constant((homeVM.sessionCard.meetingCollaborations ?? []).compactMap({
                  $0.username
              })),
                arrTalent: .constant(homeVM.sessionCard.meetingCollaborations ?? [])) {
                    homeVM.isShowCollabList = false
                } visitProfile: { item in
                    homeVM.isShowSessionDetail = false
                    homeVM.username = item
                    homeVM.routeToTalentProfile()
                }
                .dynamicTypeSize(.large)
            }
        })
    }
}

struct UserHomeView_Previews: PreviewProvider {
    static var previews: some View {
        UserHomeView(tabValue: .constant(.agenda))
            .environmentObject(UserHomeViewModel())
    }
}
