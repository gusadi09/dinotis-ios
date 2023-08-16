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
                    
                    Color.homeBgColor
                        .edgesIgnoringSafeArea(.bottom)
                    
                    VStack(spacing: 0) {
                        
                        HeaderView()
                            .environmentObject(homeVM)
                            .onChange(of: state.isGoToDetailSchedule) { value in
                                if value {
                                    homeVM.routeToScheduleList()
                                }
                            }
                        
                        ScrolledContent(geo: geo)
                            .environmentObject(homeVM)
                        
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
                if homeVM.homeContent.isEmpty {
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
    }
}

struct UserHomeView_Previews: PreviewProvider {
    static var previews: some View {
        UserHomeView(tabValue: .constant(.agenda))
            .environmentObject(UserHomeViewModel())
    }
}
