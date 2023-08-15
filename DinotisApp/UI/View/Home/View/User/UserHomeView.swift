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
    
    @ObservedObject var homeVM: UserHomeViewModel
    @ObservedObject var state = StateObservable.shared
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    @Binding var tabValue: TabRoute
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                NavigationHelper(homeVM: homeVM, tabValue: $tabValue)
                
                ZStack(alignment: .center) {
                    
                    Color.homeBgColor
                        .edgesIgnoringSafeArea(.bottom)
                    
                    VStack(spacing: 0) {
                        
                        HeaderView(homeVM: homeVM)
                            .onChange(of: state.isGoToDetailSchedule) { value in
                                if value {
                                    homeVM.routeToScheduleList()
                                }
                            }
                        
                        ScrolledContent(homeVM: homeVM, geo: geo)
                        
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
                .onAppear {
                    if homeVM.homeContent.isEmpty {
                        homeVM.onScreenAppear(geo: geo)
                    }
                    
                    AppDelegate.orientationLock = .portrait
                }
            }
        }
    }
}

struct UserHomeView_Previews: PreviewProvider {
    static var previews: some View {
        UserHomeView(homeVM: UserHomeViewModel(), tabValue: .constant(.agenda))
    }
}
