//
//  TalentHomeView.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/08/21.
//

import CurrencyFormatter
import DinotisData
import DinotisDesignSystem
import Introspect
import SwiftUI
import SwiftUINavigation
import SwiftUITrackableScrollView

struct TalentHomeView: View {
    
    @EnvironmentObject var homeVM: TalentHomeViewModel
    @ObservedObject var state = StateObservable.shared
    
    var body: some View {
        if homeVM.isFromUserType {
            MainView(homeVM: homeVM, state: state)
        } else {
            NavigationView {
                MainView(homeVM: homeVM, state: state)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
        }
    }
    
    struct MainView: View {
        
        @ObservedObject var homeVM: TalentHomeViewModel
        @ObservedObject var state: StateObservable
        
        @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
        
        var viewController: UIViewController? {
            self.viewControllerHolder.value
        }

        private var columns: [GridItem] {
            [GridItem](
                repeating: GridItem(.flexible(), spacing: 30),
                count: 3
            )
        }
        
        var body: some View {
            ZStack {
                
                NavigationLink(
                    unwrapping: $homeVM.route,
                    case: /HomeRouting.notification) { viewModel in
                        NotificationView(viewModel: viewModel.wrappedValue)
                    } onNavigate: { _ in
                        
                    } label: {
                        EmptyView()
                    }
                
                NavigationLink(
                    unwrapping: $homeVM.route,
                    case: /HomeRouting.editScheduleMeeting,
                    destination: { viewModel in
                        EditTalentMeetingView(viewModel: viewModel.wrappedValue)
                    },
                    onNavigate: { _ in },
                    label: {
                        EmptyView()
                    }
                )
                .alert(isPresented: $homeVM.isShowDelete) {
                    Alert(
                        title: Text(LocaleText.attention),
                        message: Text(LocaleText.deleteAlertText),
                        primaryButton: .default(
                            Text(LocaleText.noText)
                        ),
                        secondaryButton: .destructive(
                            Text(LocaleText.yesDeleteText),
                            action: {
                                Task {
                                    await homeVM.deleteMeeting()
                                }
                            }
                        )
                    )
                }
                
                ZStack(alignment: .bottom) {
                    
                    ZStack(alignment: .bottomTrailing) {
                        VStack {
                            LinearGradient(colors: [.secondaryBackground, .white, .white], startPoint: .top, endPoint: .bottom)
                                .edgesIgnoringSafeArea([.top, .horizontal])
                                .alert(isPresented: $homeVM.isError) {
                                    Alert(
                                        title: Text(LocaleText.attention),
                                        message: Text(homeVM.error.orEmpty()),
                                        dismissButton: .cancel(Text(LocaleText.returnText))
                                    )
                                }
                        }
                        
                        VStack {
                            VStack(spacing: 0) {
                                HStack {
                                    Button(action: {
                                        homeVM.routeToProfile()
                                    }, label: {
                                        HStack(spacing: 15) {
                                            ProfileImageContainer(
                                                profilePhoto: $homeVM.photoProfile,
                                                name: $homeVM.nameOfUser,
                                                width: 48,
                                                height: 48
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 2)
                                            )
                                            .shadow(color: Color(red: 0.22, green: 0.29, blue: 0.41).opacity(0.06), radius: 20, x: 0, y: 0)
                                            
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text(LocaleText.helloText)
                                                    .font(.robotoRegular(size: 12))
                                                    .foregroundColor(.black)
                                                    .padding(.bottom, 6)
                                                
                                                Text((homeVM.userData?.name).orEmpty())
                                                    .font(.robotoBold(size: 14))
                                                    .foregroundColor(.black)
                                            }
                                        }
                                        
                                    })
                                    
                                    NavigationLink(
                                        unwrapping: $homeVM.route,
                                        case: /HomeRouting.talentProfile) { viewModel in
                                            TalentProfileView()
                                                .environmentObject(viewModel.wrappedValue)
                                        } onNavigate: { _ in
                                            
                                        } label: {
                                            EmptyView()
                                        }
                                    
                                    NavigationLink(
                                        unwrapping: $homeVM.route,
                                        case: /HomeRouting.talentRateCardList) { viewModel in
                                            TalentCardListView(viewModel: viewModel.wrappedValue)
                                        } onNavigate: { _ in
                                            
                                        } label: {
                                            EmptyView()
                                        }
                                    
                                    Spacer()
                                    
                                    Button {
                                        
                                    } label: {
                                        ZStack(alignment: .topTrailing) {
                                            
                                            Circle()
                                                .scaledToFit()
                                                .frame(height: 48)
                                                .foregroundColor(Color.white)
                                                .overlay(
                                                    Image.homeTalentChatPrimaryIcon
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 21)
                                                )
                                                .shadow(color: Color(red: 0.22, green: 0.29, blue: 0.41).opacity(0.06), radius: 20, x: 0, y: 0)
                                            
                                            //                                        if homeVM.hasNewNotif {
                                            Text("9+")
                                                .font(.robotoMedium(size: 12))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 3)
                                                .padding(.vertical, 1)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .foregroundColor(.red)
                                                )
                                            
                                            //                                        }
                                        }
                                    }
                                    .isHidden(true, remove: true)
                                    
                                    Button {
                                        homeVM.routeToNotification()
                                    } label: {
                                        ZStack(alignment: .topTrailing) {
                                            
                                            Circle()
                                                .scaledToFit()
                                                .frame(height: 48)
                                                .foregroundColor(Color.white)
                                                .overlay(
                                                    Image.homeTalentNotificationIcon
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 20)
                                                )
                                                .shadow(color: Color(red: 0.22, green: 0.29, blue: 0.41).opacity(0.06), radius: 20, x: 0, y: 0)
                                            
                                            if homeVM.hasNewNotif {
                                                Text(homeVM.notificationBadgeCountStr)
                                                    .font(.robotoMedium(size: 12))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 3)
                                                    .padding(.vertical, 1)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 4)
                                                            .foregroundColor(.red)
                                                    )
                                                
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .padding(.top, 10)
                                .alert(isPresented: $homeVM.isSuccessDelete) {
                                    Alert(
                                        title: Text(LocaleText.successTitle),
                                        message: Text(LocaleText.meetingDeleted),
                                        dismissButton: .default(Text(LocaleText.returnText), action: {
                                            
                                        }))
                                }
                                
                                DinotisList {
                                    Task {
                                        homeVM.isShowAdditionalContent.toggle()
                                        await homeVM.refreshList()
                                    }
                                    
                                } introspectConfig: { view in
                                    view.separatorStyle = .none
                                    view.showsVerticalScrollIndicator = false
                                    homeVM.use(for: view) { refresh in
                                        Task {
                                            await homeVM.refreshList()
                                            refresh.endRefreshing()
                                        }
                                    }
                                } content: {
                                    Section {
                                        VStack(spacing: 12) {
                                            HStack(spacing: 15) {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text(LocaleText.walletBalance)
                                                        .font(.robotoRegular(size: 12))
                                                        .foregroundColor(.black)
                                                    
                                                    Text(homeVM.currentBalances.toCurrency())
                                                        .font(.robotoBold(size: 18))
                                                        .foregroundColor(.black)
                                                        .lineLimit(1)
                                                }
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    homeVM.routeToWallet()
                                                }, label: {
                                                    HStack(spacing: 8) {
                                                        Image.homeTalentWalletIcon
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 16)
                                                        
                                                        Text(LocalizableText.homeCreatorWithdraw)
                                                            .font(.robotoBold(size: 14))
                                                            .foregroundColor(.black)
                                                            .fixedSize(horizontal: true, vertical: false)
                                                    }
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .foregroundColor(.DinotisDefault.lightPrimary)
                                                    )
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .inset(by: 0.5)
                                                            .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                                    )
                                                })
                                                .buttonStyle(.plain)
                                            }
                                            .padding(.vertical, 24)
                                            .overlay(
                                                Divider()
                                                    .foregroundColor(Color.DinotisDefault.smokeWhite),
                                                alignment: .bottom
                                            )
                                            
                                            LazyVGrid(columns: columns) {
                                                Button {
                                                    homeVM.routeToTalentFormSchedule()
                                                } label: {
                                                    VStack {
                                                        Image.Dinotis.redCameraVideoIcon
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 24)
                                                            .padding(8)
                                                            .background(Color.secondaryViolet)
                                                            .frame(width: 36, height: 36)
                                                            .cornerRadius(8)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                    .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                                                    .frame(width: 36, height: 36)
                                                            )
                                                        
                                                        Text(LocaleText.createSessionSchedule)
                                                            .foregroundColor(.black)
                                                            .font(.robotoRegular(size: 10))
                                                            .multilineTextAlignment(.center)
                                                    }
                                                }
                                                .buttonStyle(.plain)
                                                
                                                Button {
                                                    homeVM.routeToBundling()
                                                } label: {
                                                    VStack {
                                                        ZStack(alignment: .topTrailing) {
                                                            Image.Dinotis.redPricetagIcon
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 24)
                                                                .padding(8)
                                                                .background(Color.secondaryViolet)
                                                                .frame(width: 36, height: 36)
                                                                .cornerRadius(8)
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 8)
                                                                        .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                                                        .frame(width: 36, height: 36)
                                                                )
                                                            
                                                            Image.Dinotis.newBadgeIcon
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 18, height: 10)
                                                                .padding(.top, -5)
                                                                .padding(.trailing, -9)
                                                        }
                                                        
                                                        Text(LocaleText.talentHomeBundlingMenu)
                                                            .foregroundColor(.black)
                                                            .font(.robotoRegular(size: 10))
                                                            .multilineTextAlignment(.center)
                                                    }
                                                }
                                                .buttonStyle(.plain)
                                                
                                                Button {
                                                    homeVM.routeToTalentRateCardList()
                                                } label: {
                                                    VStack {
                                                        ZStack(alignment: .topTrailing) {
                                                            Image.Dinotis.rateCardIcon
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 36, height: 36)
                                                            
                                                            Image.Dinotis.newBadgeIcon
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 18, height: 10)
                                                                .padding(.top, -5)
                                                                .padding(.trailing, -9)
                                                        }
                                                        
                                                        Text(LocaleText.rateCardMenu)
                                                            .foregroundColor(.black)
                                                            .font(.robotoRegular(size: 10))
                                                            .multilineTextAlignment(.center)
                                                    }
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            .padding(.vertical, 12)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 25)
                                        .background(
                                            RoundedRectangle(cornerRadius: 11)
                                                .foregroundColor(.white)
                                                .shadow(color: Color.dinotisShadow.opacity(0.08), radius: 8, x: 0, y: 0)
                                        )
                                        .padding(.top, 10)
                                    }
                                    .listRowBackground(Color.clear)
                                    
                                    if !homeVM.closestSessions.isEmpty {
                                        Section {
                                            VStack {
                                                HStack {
                                                    Text(LocalizableText.homeCreatorNearestTitle)
                                                        .font(.robotoRegular(size: 16))
                                                        .fontWeight(.semibold)
                                                    
                                                    Spacer()
                                                }
                                                .padding(.horizontal)
                                                
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    LazyHStack {
                                                        ForEach(homeVM.closestSessions, id: \.id) { item in
                                                            SessionCard(
                                                                with: SessionCardModel(
                                                                    title: (item.title).orEmpty(),
                                                                    date: DateUtils.dateFormatter((item.startAt).orCurrentDate(), forFormat: .ddMMMMyyyy),
                                                                    startAt: DateUtils.dateFormatter((item.startAt).orCurrentDate(), forFormat: .HHmm),
                                                                    endAt: DateUtils.dateFormatter((item.endAt).orCurrentDate(), forFormat: .HHmm),
                                                                    isPrivate: (item.isPrivate) ?? false,
                                                                    isVerified: (item.user?.isVerified) ?? false,
                                                                    photo: (item.user?.profilePhoto).orEmpty(),
                                                                    name: (item.user?.name).orEmpty(),
                                                                    color: item.background,
                                                                    participantsImgUrl: item.participantDetails?.compactMap({
                                                                        $0.profilePhoto.orEmpty()
                                                                    }) ?? [],
                                                                    isActive: item.endAt.orCurrentDate() > Date(),
                                                                    collaborationCount: (item.meetingCollaborations ?? []).count,
                                                                    collaborationName: (item.meetingCollaborations ?? []).compactMap({
                                                                        (
                                                                            $0.user?.name
                                                                        ).orEmpty()
                                                                    }).joined(separator: ", "),
                                                                    isAlreadyBooked: false
                                                                )
                                                            ) {
                                                                homeVM.routeToTalentDetailSchedule(meetingId: item.id.orEmpty())
                                                            } visitProfile: {
                                                                
                                                            }
                                                            .frame(width: 310)
                                                        }
                                                        .padding(.bottom, 5)
                                                    }
                                                    .padding(.horizontal)
                                                }
                                            }
                                            .padding(.vertical, 10)
                                        }
                                        .listRowBackground(Color.clear)
                                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                    }
                                }
                                .alert(isPresented: $homeVM.isRefreshFailed) {
                                    Alert(
                                        title: Text(LocaleText.attention),
                                        message: Text(LocaleText.sessionExpireText),
                                        dismissButton: .default(Text(LocaleText.returnText), action: {
                                            
                                            homeVM.routeBack()
                                        }))
                                }
                                
                            }
                            .frame(height: !homeVM.closestSessions.isEmpty ? 570 : 340)
                            
                            Spacer()
                        }
                        
                    }
                    
                    NavigationLink(
                        unwrapping: $homeVM.route,
                        case: /HomeRouting.talentFormSchedule,
                        destination: { viewModel in
                            ScheduledFormView(viewModel: viewModel.wrappedValue)
                        },
                        onNavigate: { _ in },
                        label: {
                            EmptyView()
                        }
                    )
                    .alert(isPresented: $homeVM.successConfirm) {
                        Alert(
                            title: Text(LocaleText.successTitle),
                            message: Text(LocaleText.successConfirmRequestText),
                            dismissButton: .default(Text(LocaleText.okText))
                        )
                    }
                    
                    NavigationLink(
                        unwrapping: $homeVM.route,
                        case: /HomeRouting.talentWallet,
                        destination: { viewModel in
                            TalentWalletView(viewModel: viewModel.wrappedValue)
                        },
                        onNavigate: { _ in },
                        label: {
                            EmptyView()
                        }
                    )
                    
                    NavigationLink(
                        unwrapping: $homeVM.route,
                        case: /HomeRouting.bundlingMenu,
                        destination: { viewModel in
                            BundlingView(viewModel: viewModel.wrappedValue)
                        },
                        onNavigate: { _ in },
                        label: {
                            EmptyView()
                        }
                    )
                    
                    NavigationLink(
                        unwrapping: $homeVM.route,
                        case: /HomeRouting.talentScheduleDetail,
                        destination: { viewModel in
                            TalentScheduleDetailView(viewModel: viewModel.wrappedValue)
                        },
                        onNavigate: { _ in },
                        label: {
                            EmptyView()
                        }
                    )
                    .alert(isPresented: $homeVM.isErrorAdditionalShow) {
                        Alert(
                            title: Text(LocaleText.errorText),
                            message: Text(homeVM.error.orEmpty()),
                            dismissButton: .cancel(Text(LocaleText.returnText))
                        )
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
                    
                    Color.white
                        .cornerRadius(homeVM.translation.height > homeVM.getBottomSafeArea() ? 24 : 0, corners: [.topLeft, .topRight])
                        .ignoresSafeArea(edges: .bottom)
                        .frame(height: homeVM.getBottomSafeArea() + (homeVM.translation.height > homeVM.getBottomSafeArea() ? .zero : -homeVM.translation.height))
                        .onChange(of: homeVM.isSortByLatestPending) { newValue in
                            homeVM.onChangeSortPending(isLatest: newValue)
                        }
                        .onChange(of: homeVM.isSortByLatestEnded) { newValue in
                            homeVM.onChangeSortEnded(isLatest: newValue)
                        }
                        .onChange(of: homeVM.isSortByLatestCanceled) { newValue in
                            homeVM.onChangeSortCanceled(isLatest: newValue)
                        }
                    
                    TalentHomeBottomSheet(viewModel: homeVM) {
                        Group {
                            switch homeVM.currentSection {
                            case .scheduled:
                                ScheduledSessionView(viewModel: homeVM)
                            case .notConfirmed:
                                RequestedSessionView(viewModel: homeVM)
                            case .pending:
                                PendingSessionView(viewModel: homeVM)
                            case .canceled:
                                CanceledSessionView(viewModel: homeVM)
                            case .completed:
                                CompletedSessionView(viewModel: homeVM)
                            }
                        }
                    } header: {
                        Group {
                            switch homeVM.currentSection {
                            case .scheduled:
                                EmptyView()
                            default:
                                HStack {
                                    HStack(spacing: 12) {
                                        Image(systemName: "slider.horizontal.3")
                                        
                                        Text(LocalizableText.sortLabel)
                                            .font(.robotoBold(size: 12))
                                    }
                                    .foregroundColor(.DinotisDefault.primary)
                                    
                                    Spacer()
                                    
                                    Menu {
                                        Button {
                                            withAnimation {
                                                homeVM.sortSelectionActionLatest()
                                            }
                                        } label: {
                                            HStack {
                                                Text(LocalizableText.sortLatest)
                                                
                                                Image(systemName: "checkmark")
                                                    .isHidden(!homeVM.sortSectionHiddenValue())
                                                
                                            }
                                        }
                                        
                                        Button {
                                            withAnimation {
                                                homeVM.sortSelectionActionEarliest()
                                            }
                                        } label: {
                                            HStack {
                                                Text(LocalizableText.sortEarliest)
                                                
                                                Image(systemName: "checkmark")
                                                    .isHidden(homeVM.sortSectionHiddenValue())
                                            }
                                        }
                                        
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(homeVM.sortSectionHiddenValue() ? LocalizableText.sortLatest : LocalizableText.sortEarliest)
                                                .font(.robotoMedium(size: 12))
                                            
                                            Image(systemName: "chevron.down")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 10, height: 5)
                                        }
                                        .foregroundColor(.DinotisDefault.primary)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 9)
                                        .background(Color.DinotisDefault.lightPrimary)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .inset(by: 0.5)
                                                .stroke(Color.DinotisDefault.primary, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                    }
                    
                    DinotisLoadingView(.fullscreen, hide: !homeVM.isLoading)
                    
                    DinotisLoadingView(.fullscreen, hide: !homeVM.isLoadingConfirm)
                }
                .navigationBarTitle(Text(""))
                .navigationBarHidden(true)
                .onAppear(perform: {
                    homeVM.onAppearView()
                })
                .onDisappear {
                    homeVM.resetParameterQuery()
                }
                .sheet(
                    item: $homeVM.confirmationSheet,
                    content: { item in
                        switch item {
                        case .accepted:
                            if #available(iOS 16.0, *) {
                                AcceptedSheet(viewModel: homeVM, isOnSheet: true)
                                    .padding()
                                    .presentationDetents([.medium])
                                    .presentationDragIndicator(.hidden)
                                    .dynamicTypeSize(.large)
                            } else {
                                AcceptedSheet(viewModel: homeVM, isOnSheet: false)
                                    .dynamicTypeSize(.large)
                            }
                        case .declined:
                            if #available(iOS 16.0, *) {
                                DeclinedSheet(viewModel: homeVM, isOnSheet: true)
                                    .padding()
                                    .presentationDetents([.medium])
                                    .dynamicTypeSize(.large)
                            } else {
                                DeclinedSheet(viewModel: homeVM, isOnSheet: false)
                                    .dynamicTypeSize(.large)
                            }
                        }
                    }
                )
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: .creatorMeetingDetail, object: nil, queue: .main) { _ in
                    homeVM.routeToTalentDetailSchedule(meetingId: state.meetingId)
                }
                
                NotificationCenter.default.addObserver(forName: .creatorHome, object: nil, queue: .main) { _ in
                    homeVM.route = nil
                }
                
                withAnimation {
                    homeVM.offsetY = !homeVM.closestSessions.isEmpty ? 562 : 344
                }
            }
            .onChange(of: homeVM.closestSessions.isEmpty) { newValue in
                withAnimation {
                    homeVM.offsetY = !homeVM.closestSessions.isEmpty ? 562 : 344
                }
            }
        }
    }
}

extension TalentHomeView {
    
    struct TalentHomeBottomSheet<Content: View, Header: View>: View {
        var content: Content
        var header: Header
        @ObservedObject var viewModel: TalentHomeViewModel
        
        init(viewModel: TalentHomeViewModel, content: @escaping () -> Content, header: @escaping () -> Header) {
            self.content = content()
            self.header = header()
            self.viewModel = viewModel
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 119, height: 4)
                        .background(Color(red: 0.91, green: 0.91, blue: 0.91))
                        .cornerRadius(36)
                    
                    Spacer()
                }
                .padding(.vertical)
                
                VStack(spacing: 16) {
                    ScrollViewReader { scrollView in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(viewModel.tabSections, id: \.self) { tab in
                                    Button {
                                        withAnimation {
                                            viewModel.currentSection = tab
                                            scrollView.scrollTo(tab, anchor: .center)
                                            viewModel.offsetY = .zero
                                            switch tab {
                                            case .scheduled:
                                                viewModel.onGetScheduledMeeting(isMore: false)
                                            case .notConfirmed:
                                                viewModel.onGetMeetingRequest(isMore: false)
                                            case .pending:
                                                viewModel.onGetPendingMeeting(isMore: false)
                                            case .canceled:
                                                viewModel.onGetCanceledMeeting(isMore: false)
                                            case .completed:
                                                viewModel.onGetEndedMeeting(isMore: false)
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Text(headerText(for: tab))
                                                .font(tab == viewModel.currentSection ? .robotoBold(size: 14) : .robotoRegular(size: 14))
                                                .foregroundColor(tab == viewModel.currentSection ? .DinotisDefault.primary : .DinotisDefault.black1)
                                                .frame(maxWidth: .infinity)
                                            
                                            switch tab {
                                            case .scheduled:
                                                Text(viewModel.scheduledCounter.orEmpty())
                                                    .font(.robotoBold(size: 12))
                                                    .foregroundColor(.white)
                                                    .padding(4)
                                                    .frame(width: 28)
                                                    .background(Color.DinotisDefault.primary)
                                                    .cornerRadius(6)
                                                    .isHidden(viewModel.scheduledCounter == nil || viewModel.scheduledCounter.orEmpty() == "0", remove: viewModel.scheduledCounter == nil || viewModel.scheduledCounter.orEmpty() == "0")
                                            case .notConfirmed:
                                                Text(viewModel.counterRequest)
                                                    .font(.robotoBold(size: 12))
                                                    .foregroundColor(.white)
                                                    .padding(4)
                                                    .frame(width: 28)
                                                    .background(Color.DinotisDefault.primary)
                                                    .cornerRadius(6)
                                                    .isHidden(viewModel.counterRequest.isEmpty || viewModel.counterRequest == "0", remove: viewModel.counterRequest.isEmpty || viewModel.counterRequest == "0")
                                            case .pending:
                                                Text(viewModel.pendingCounter.orEmpty())
                                                    .font(.robotoBold(size: 12))
                                                    .foregroundColor(.white)
                                                    .padding(4)
                                                    .frame(width: 28)
                                                    .background(Color.DinotisDefault.primary)
                                                    .cornerRadius(6)
                                                    .isHidden(viewModel.pendingCounter == nil || viewModel.pendingCounter.orEmpty() == "0", remove: viewModel.pendingCounter == nil || viewModel.pendingCounter.orEmpty() == "0")
                                            case .canceled:
                                                Text(viewModel.canceledCounter.orEmpty())
                                                    .font(.robotoBold(size: 12))
                                                    .foregroundColor(.white)
                                                    .padding(4)
                                                    .frame(width: 28)
                                                    .background(Color.DinotisDefault.primary)
                                                    .cornerRadius(6)
                                                    .isHidden(viewModel.canceledCounter == nil || viewModel.canceledCounter.orEmpty() == "0", remove: viewModel.canceledCounter == nil || viewModel.canceledCounter
                                                        .orEmpty() == "0")
                                            case .completed:
                                                Text(viewModel.endedCounter.orEmpty())
                                                    .font(.robotoBold(size: 12))
                                                    .foregroundColor(.white)
                                                    .padding(4)
                                                    .frame(width: 32)
                                                    .background(Color.DinotisDefault.primary)
                                                    .cornerRadius(6)
                                                    .isHidden(viewModel.endedCounter == nil || viewModel.endedCounter.orEmpty() == "0", remove: viewModel.endedCounter == nil || viewModel.endedCounter.orEmpty() == "0")
                                            }
                                        }
                                        .padding(12)
                                        .frame(maxHeight: 38)
                                        .cornerRadius(20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(tab == viewModel.currentSection ? Color.DinotisDefault.lightPrimary : .white)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .inset(by: 0.5)
                                                .stroke(Color.DinotisDefault.lightPrimary, lineWidth: 1)
                                        )
                                    }
                                    .id(tab)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Rectangle()
                        .fill(Color.DinotisDefault.lightPrimary)
                        .frame(height: 1)
                    
                    header
                        .padding([.bottom, .horizontal])
                }
                
                ScrollView(showsIndicators: false) {
                    content
                        .padding(.horizontal)
                        .offset("SCROLL") { scroll in
                            withAnimation(.spring(response: 0.4)) {
                                if viewModel.offsetY < viewModel.sheetHeight {
                                    if scroll > 60 {
                                        viewModel.offsetY = viewModel.sheetHeight
                                    }
                                } else {
                                    if scroll < -60 {
                                        viewModel.offsetY = .zero
                                    }
                                }
                            }
                        }
                }
                .coordinateSpace(name: "SCROLL")
            }
            .background(
                VStack(spacing: 0) {
                    Color.white
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                        .shadow(color: Color(red: 0.61, green: 0.69, blue: 0.81).opacity(0.32), radius: 13.5, x: 0, y: 0)
                    Color.white
                }
            )
            .ignoresSafeArea(edges: .bottom)
            .offset(y: viewModel.translation.height + viewModel.offsetY)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        if viewModel.offsetY < viewModel.sheetHeight+20 {
                            viewModel.translation = value.translation
                        }
                    })
                    .onEnded({ value in
                        withAnimation(.spring(response: 0.5)) {
                            if value.translation.height < -80 {
                                viewModel.offsetY = .zero
                            } else {
                                viewModel.offsetY = viewModel.sheetHeight
                            }
                            viewModel.translation = .zero
                            
                        }
                    })
            )
        }
        
        private func headerText(for tab: TalentHomeSection) -> String {
            switch tab {
            case .scheduled:
                return LocalizableText.filterScheduled
            case .notConfirmed:
                return LocalizableText.filterUnconfirmed
            case .pending:
                return LocalizableText.filterPending
            case .canceled:
                return LocalizableText.filterCanceled
            case .completed:
                return LocalizableText.filterSessionCompleted
            }
        }
    }

	struct DeclinedSheet: View {

		@ObservedObject var viewModel: TalentHomeViewModel
		@State var selectedReason = [CancelOptionData]()
		@State var report = ""
		let isOnSheet: Bool

		var body: some View {
			VStack(spacing: 25) {
				HStack {
					Text(LocaleText.cancelConfirmationText)
						.font(.robotoBold(size: 14))
						.foregroundColor(.black)

					Spacer()

					Button(action: {
						viewModel.confirmationSheet = nil
					}, label: {
						Image(systemName: "xmark")
							.resizable()
							.scaledToFit()
							.frame(height: 10)
							.font(.system(size: 10, weight: .bold, design: .rounded))
							.foregroundColor(.black)
					})
				}

				LazyVStack(spacing: 15) {
					ForEach(viewModel.cancelOptionData.unique(), id: \.id) { item in
						Button {
							if isSelected(item: item, arrSelected: selectedReason) {
								if let itemToRemoveIndex = selectedReason.firstIndex(of: item) {
									selectedReason.remove(at: itemToRemoveIndex)
								}
							} else {
								selectedReason.append(item)
							}
						} label: {
							HStack(alignment: .top) {
								if isSelected(item: item, arrSelected: selectedReason) {
									Image.Dinotis.filledChecklistIcon
										.resizable()
										.scaledToFit()
										.frame(height: 15)
								} else {
									Image.Dinotis.emptyChecklistIcon
										.resizable()
										.scaledToFit()
										.frame(height: 15)
								}

								Text(item.name.orEmpty())
									.font(.robotoRegular(size: 12))
									.foregroundColor(.black)
									.multilineTextAlignment(.leading)

								Spacer()
							}
						}
					}

					if selectedReason.contains(where: { $0.id == 5 }) {
						TextField(LocaleText.reportNotesPlaceholder, text: $report)
							.font(.robotoRegular(size: 12))
							.foregroundColor(.black)
							.accentColor(.black)
							.disableAutocorrection(true)
							.autocapitalization(.none)
							.padding(10)
							.background(
								RoundedRectangle(cornerRadius: 10)
									.foregroundColor(.white)
							)
							.clipped()
							.overlay(
								RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray5), lineWidth: 1)
							)
							.shadow(color: Color.dinotisShadow.opacity(0.06), radius: 40, x: 0.0, y: 0.0)
					}
				}

				if isOnSheet {
					Spacer()
				}

				Button {
					Task {
						let selected = selectedReason.compactMap({ $0.id })
						await viewModel.confirmRequest(
							isAccepted: false,
							reasons: selected,
							otherReason: report
						)
					}
				} label: {
					HStack {

						Spacer()

						Text(LocaleText.sendText)
							.font(.robotoMedium(size: 12))
							.foregroundColor(selectedReason.isEmpty || (selectedReason.contains(where: { $0.id == 5 }) && report.isEmpty) ? Color(.systemGray2) : .white)

						Spacer()
					}
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(selectedReason.isEmpty || (selectedReason.contains(where: { $0.id == 5 }) && report.isEmpty) ? Color(.systemGray5) : .DinotisDefault.primary)
					)
				}
				.disabled(selectedReason.isEmpty || (selectedReason.contains(where: { $0.id == 5 }) && report.isEmpty))

			}
		}

		func isSelected(item: CancelOptionData, arrSelected: [CancelOptionData]) -> Bool {
			arrSelected.contains(where: { $0.id == item.id })
		}
	}

	struct AcceptedSheet: View {

		@ObservedObject var viewModel: TalentHomeViewModel
		@State var isAccepted = false
		let isOnSheet: Bool

		var body: some View {
			VStack(spacing: 25) {
				HStack {
					Text(LocaleText.acceptanceConfirmationText)
						.font(.robotoBold(size: 14))
						.foregroundColor(.black)

					Spacer()

					Button(action: {
						viewModel.confirmationSheet = nil
					}, label: {
						Image(systemName: "xmark")
							.resizable()
							.scaledToFit()
							.frame(height: 10)
							.font(.system(size: 10, weight: .bold, design: .rounded))
							.foregroundColor(.black)
					})
				}

				VStack(spacing: 15) {
					Text(LocaleText.acceptanceDescriptionText)
						.font(.robotoRegular(size: 12))
						.multilineTextAlignment(.leading)
						.foregroundColor(.black)

					Button {
						isAccepted.toggle()
					} label: {
						HStack(alignment: .top) {
							if isAccepted {
								Image.Dinotis.filledChecklistIcon
									.resizable()
									.scaledToFit()
									.frame(height: 15)
							} else {
								Image.Dinotis.emptyChecklistIcon
									.resizable()
									.scaledToFit()
									.frame(height: 15)
							}

							Text(LocaleText.privacyPolicyRateCardAcceptance)
								.font(.robotoRegular(size: 12))
								.foregroundColor(.gray)
								.multilineTextAlignment(.leading)

							Spacer()
						}
					}
				}

				if isOnSheet {
					Spacer()
				}

				Button {
					Task {
						await viewModel.confirmRequest(
							isAccepted: true,
							reasons: nil,
							otherReason: nil
						)
					}
				} label: {
					HStack {

						Spacer()

						Text(LocaleText.sendText)
							.font(.robotoMedium(size: 12))
							.foregroundColor(!isAccepted ? Color(.systemGray2) : .white)

						Spacer()
					}
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 12)
							.foregroundColor(!isAccepted ? Color(.systemGray5) : .DinotisDefault.primary)
					)
				}
				.disabled(!isAccepted)

			}
		}
	}
	
	struct EmptyStateView: View {

		let title: String
		let description: String
		let buttonText: String
		var primaryAction: () -> Void

		var body: some View {
			VStack(spacing: 10) {
				Image.Dinotis.emptyScheduleImage
					.resizable()
					.scaledToFit()
					.frame(
						height: 137
					)

				Text(title)
					.font(.robotoBold(size: 14))
					.foregroundColor(.black)

				Text(description)
					.font(.robotoRegular(size: 12))
					.multilineTextAlignment(.center)
					.foregroundColor(.black)
                    .padding(.bottom, 20)
                
                DinotisPrimaryButton(
                    text: buttonText,
                    type: .adaptiveScreen,
                    textColor: .white,
                    bgColor: .DinotisDefault.primary
                ) {
                    primaryAction()
                }
			}
		}
	}
    
    struct ScheduledSessionView: View {
        
        @ObservedObject var viewModel: TalentHomeViewModel
        
        var body: some View {
            LazyVStack(alignment: .leading, spacing: 12) {
                if !viewModel.scheduledData.unique().isEmpty {
                    ForEach(viewModel.scheduledData.unique(), id: \.id) { meeting in
                        TalentScheduleCardView(
                            isShowMenu: true,
                            data: .constant(meeting),
                            isShowCollabList: false,
                            isBundle: false) {
                                viewModel.routeToTalentDetailSchedule(meetingId: meeting.id.orEmpty())
                            } onTapEdit: {
                                viewModel.routeToEditSchedule(id: meeting.id.orEmpty())
                            } onTapDelete: {
                                viewModel.meetingId = meeting.id.orEmpty()
                                viewModel.isShowDelete.toggle()
                            }
                            .onAppear {
                                if (viewModel.scheduledData.unique().last?.id).orEmpty() == meeting.id {
                                    Task {
                                        viewModel.scheduledRequest.skip = viewModel.scheduledRequest.take
                                        viewModel.scheduledRequest.take += 8
                                        await viewModel.getScheduledMeeting(isMore: true)
                                    }
                                }
                            }
                    }
                    if viewModel.isLoadingMoreScheduled {
                        HStack {
                            Spacer()
                            
                            ProgressView()
                                .progressViewStyle(.circular)
                            
                            Spacer()
                        }
                        .animation(.spring(), value: viewModel.isLoadingMoreScheduled)
                    }
                    
                } else {
                    EmptyStateView(
                        title: LocalizableText.creatorEmptySessionTitle,
                        description: LocalizableText.creatorEmptySessionDesc,
                        buttonText: LocalizableText.creatorCreateSessionLabel) {
                            viewModel.routeToTalentFormSchedule()
                        }
                }
            }
            .padding(.vertical)
            .animation(.spring(), value: viewModel.isLoadingMoreScheduled)
        }
    }
    
    struct RequestedSessionView: View {
        
        @ObservedObject var viewModel: TalentHomeViewModel
        
        var body: some View {
            LazyVStack(alignment: .leading, spacing: 12) {
                if !viewModel.meetingRequestData.unique().isEmpty {
                    ForEach(viewModel.meetingRequestData.sorted(by: { $0.createdAt?.compare($1.createdAt.orCurrentDate()) == (viewModel.isSortByLatestNotConfirmed ? .orderedDescending : .orderedAscending) }).unique(), id: \.id) { item in
                        RequestCardView(
                            user: item.user,
                            item: item,
                            onTapDecline: {
                                viewModel.requestId = item.id.orEmpty()
                                viewModel.confirmationSheet = .declined
                            },
                            onTapAccept: {
                                viewModel.requestId = item.id.orEmpty()
                                viewModel.confirmationSheet = .accepted
                            }
                        )
                        .onAppear {
                            Task {
                                if item.id == viewModel.meetingRequestData.unique().last?.id {
                                    viewModel.rateCardQuery.skip = viewModel.rateCardQuery.take
                                    viewModel.rateCardQuery.take += 15
                                    await viewModel.getMeetingRequest(isMore: true)
                                }
                            }
                        }
                    }
                    
                    if viewModel.isLoadingMoreRequest {
                        HStack {
                            Spacer()
                            
                            ProgressView()
                                .progressViewStyle(.circular)
                            
                            Spacer()
                        }
                        .animation(.spring(), value: viewModel.isLoadingMoreRequest)
                    }
                    
                } else {
                    EmptyStateView(
                        title: LocalizableText.creatorEmptySessionTitle,
                        description: LocalizableText.creatorEmptySessionDesc,
                        buttonText: LocalizableText.creatorCreateSessionLabel) {
                            viewModel.routeToTalentFormSchedule()
                        }
                }
            }
            .padding(.vertical)
            .animation(.spring(), value: viewModel.isLoadingMoreRequest)
        }
    }
    
    struct PendingSessionView: View {
        
        @ObservedObject var viewModel: TalentHomeViewModel
        
        var body: some View {
            LazyVStack(alignment: .leading, spacing: 12) {
                if !viewModel.pendingData.unique().isEmpty {
                    ForEach(viewModel.pendingData.unique(), id: \.id) { meeting in
                        TalentScheduleCardView(
                            isShowMenu: true,
                            data: .constant(meeting),
                            status: viewModel.pendingStatus(of: meeting),
                            isShowCollabList: false,
                            isBundle: false) {
                                viewModel.routeToTalentDetailSchedule(meetingId: meeting.id.orEmpty())
                            } onTapEdit: {
                                viewModel.routeToEditSchedule(id: meeting.id.orEmpty())
                            } onTapDelete: {
                                viewModel.meetingId = meeting.id.orEmpty()
                                viewModel.isShowDelete.toggle()
                            }
                            .onAppear {
                                if (viewModel.pendingData.unique().last?.id).orEmpty() == meeting.id {
                                    Task {
                                        viewModel.pendingRequest.skip = viewModel.pendingRequest.take
                                        viewModel.pendingRequest.take += 8
                                        await viewModel.getPendingMeeting(isMore: true)
                                    }
                                }
                            }
                    }
                    if viewModel.isLoadingMorePending {
                        HStack {
                            Spacer()
                            
                            ProgressView()
                                .progressViewStyle(.circular)
                            
                            Spacer()
                        }
                        .animation(.spring(), value: viewModel.isLoadingMorePending)
                    }
                    
                } else {
                    EmptyStateView(
                        title: LocalizableText.creatorEmptySessionTitle,
                        description: LocalizableText.creatorEmptySessionDesc,
                        buttonText: LocalizableText.creatorCreateSessionLabel) {
                            viewModel.routeToTalentFormSchedule()
                        }
                }
            }
            .padding(.vertical)
            .animation(.spring(), value: viewModel.isLoadingMorePending)
        }
    }
    
    struct CanceledSessionView: View {
        
        @ObservedObject var viewModel: TalentHomeViewModel
        
        var body: some View {
            LazyVStack(alignment: .leading, spacing: 12) {
                if !viewModel.canceledData.unique().isEmpty {
                    ForEach(viewModel.canceledData.unique(), id: \.id) { meeting in
                        TalentScheduleCardView(
                            isShowMenu: true,
                            data: .constant(meeting),
                            status: .canceled,
                            isShowCollabList: false,
                            isBundle: false) {
                                viewModel.routeToTalentDetailSchedule(meetingId: meeting.id.orEmpty())
                            } onTapEdit: {
                                viewModel.routeToEditSchedule(id: meeting.id.orEmpty())
                            } onTapDelete: {
                                viewModel.meetingId = meeting.id.orEmpty()
                                viewModel.isShowDelete.toggle()
                            }
                            .onAppear {
                                if (viewModel.canceledData.unique().last?.id).orEmpty() == meeting.id {
                                    Task {
                                        viewModel.canceledRequest.skip = viewModel.canceledRequest.take
                                        viewModel.canceledRequest.take += 8
                                        await viewModel.getCancelledMeeting(isMore: true)
                                    }
                                }
                            }
                    }
                    if viewModel.isLoadingMoreCancelled {
                        HStack {
                            Spacer()
                            
                            ProgressView()
                                .progressViewStyle(.circular)
                            
                            Spacer()
                        }
                        .animation(.spring(), value: viewModel.isLoadingMoreCancelled)
                    }
                    
                } else {
                    EmptyStateView(
                        title: LocalizableText.creatorEmptySessionTitle,
                        description: LocalizableText.creatorEmptySessionDesc,
                        buttonText: LocalizableText.creatorCreateSessionLabel) {
                            viewModel.routeToTalentFormSchedule()
                        }
                }
            }
            .padding(.vertical)
            .animation(.spring(), value: viewModel.isLoadingMoreCancelled)
        }
    }
    
    struct CompletedSessionView: View {
        
        @ObservedObject var viewModel: TalentHomeViewModel
        
        var body: some View {
            LazyVStack(alignment: .leading, spacing: 12) {
                if !viewModel.endedData.unique().isEmpty {
                    ForEach(viewModel.endedData.unique(), id: \.id) { meeting in
                        TalentScheduleCardView(
                            isShowMenu: true,
                            data: .constant(meeting),
                            status: .completed,
                            isShowCollabList: false,
                            isBundle: false) {
                                viewModel.routeToTalentDetailSchedule(meetingId: meeting.id.orEmpty())
                            } onTapEdit: {
                                viewModel.routeToEditSchedule(id: meeting.id.orEmpty())
                            } onTapDelete: {
                                viewModel.meetingId = meeting.id.orEmpty()
                                viewModel.isShowDelete.toggle()
                            }
                            .onAppear {
                                if (viewModel.endedData.unique().last?.id).orEmpty() == meeting.id {
                                    Task {
                                        viewModel.endedRequest.skip = viewModel.endedRequest.take
                                        viewModel.endedRequest.take += 8
                                        await viewModel.getEndedMeeting(isMore: true)
                                    }
                                }
                            }
                    }
                    if viewModel.isLoadingMoreEnded {
                        HStack {
                            Spacer()
                            
                            ProgressView()
                                .progressViewStyle(.circular)
                            
                            Spacer()
                        }
                        .animation(.spring(), value: viewModel.isLoadingMoreEnded)
                    }
                    
                } else {
                    EmptyStateView(
                        title: LocalizableText.creatorEmptySessionTitle,
                        description: LocalizableText.creatorEmptySessionDesc,
                        buttonText: LocalizableText.creatorCreateSessionLabel) {
                            viewModel.routeToTalentFormSchedule()
                        }
                }
            }
            .padding(.vertical)
            .animation(.spring(), value: viewModel.isLoadingMoreEnded)
        }
    }
}

struct TalentHomeView_Previews: PreviewProvider {
    static var previews: some View {
        TalentHomeView()
            .environmentObject(TalentHomeViewModel(isFromUserType: false))
    }
}
