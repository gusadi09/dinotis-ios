//
//  ScheduleListView.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/03/22.
//

import DinotisDesignSystem
import SwiftUI
import SwiftUINavigation

struct ScheduleListView: View {
	
	@ObservedObject var viewModel: ScheduleListViewModel
	
	@Environment(\.presentationMode) var presentationMode
    
    @Binding var mainTabSelection: TabRoute
	
	var body: some View {
		ZStack {
            Group {
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.bookingInvoice,
                    destination: { viewModel in
                        UserInvoiceBookingView(
                            viewModel: viewModel.wrappedValue,
                            mainTabValue: $mainTabSelection
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
                        DetailPaymentView(viewModel: viewModel.wrappedValue, mainTabValue: $mainTabSelection)
                    },
                    onNavigate: {_ in},
                    label: {
                        EmptyView()
                    }
                )
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.paymentMethod,
                    destination: {viewModel in
                        PaymentMethodView(
                            viewModel: viewModel.wrappedValue,
                            mainTabValue: $mainTabSelection
                        )
                    },
                    onNavigate: {_ in},
                    label: {
                        EmptyView()
                    }
                )
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.talentProfileDetail,
                    destination: {viewModel in
                        TalentProfileDetailView(viewModel: viewModel.wrappedValue, tabValue: $mainTabSelection)
                    },
                    onNavigate: {_ in},
                    label: {
                        EmptyView()
                    }
                )
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.userScheduleDetail,
                    destination: {viewModel in
                        UserScheduleDetail(viewModel: viewModel.wrappedValue, mainTabValue: $mainTabSelection)
                    },
                    onNavigate: {_ in},
                    label: {
                        EmptyView()
                    }
                )
                
                NavigationLink(
                    unwrapping: $viewModel.route,
                    case: /HomeRouting.notification) { viewModel in
                        NotificationView(viewModel: viewModel.wrappedValue)
                    } onNavigate: { _ in
                        
                    } label: {
                        EmptyView()
                    }
            }
			
			Image.Dinotis.linearGradientBackground
				.resizable()
				.edgesIgnoringSafeArea(.all)
			
			VStack(spacing: 0) {
                HStack(spacing: 24) {
                    Image.logoWithText
                        .resizable()
                        .scaledToFit()
                    
                    Spacer()
                    
                    Button {
                        viewModel.routeToNotification()
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image.notificationIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 25)
                            
                            if viewModel.hasNewNotif {
                                Circle()
                                    .foregroundColor(.red)
                                    .scaledToFit()
                                    .frame(height: 8)
                            }
                        }
                    }
                    
                    Button {
                        viewModel.openWhatsApp()
                    } label: {
                        Image.generalQuestionIcon
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(height: 25)
                .padding()
                
                List {
                    Section {
                        ScrollView {
                            HStack {
                                TodayAgendaView(viewModel: viewModel)
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18))
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    
                    Section {
                        SessionListView(viewModel: viewModel, mainTabSelection: $mainTabSelection)
                    } header: {
                        SectionHeader(viewModel: viewModel)
                            .buttonStyle(.plain)
                    }
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.white)
                    .listRowInsets(EdgeInsets(top: 5, leading: 18, bottom: 0, trailing: 18))
                }
                .padding(.horizontal, -18)
                .listStyle(.plain)
                .refreshable {
                    viewModel.takeItem = 8
                    await viewModel.getBookingsList(isMore: false)
                    await viewModel.getTodayAgendaList()
                }
			}
            
            DinotisLoadingView(
                .fullscreen,
                hide: !viewModel.isLoading
            )
		}
		.onAppear {
			Task {
                await viewModel.getCounter()
				await viewModel.getTodayAgendaList()
				await viewModel.getBookingsList(isMore: false)
			}
		}
        .onDisappear {
            viewModel.onDisappear()
        }
		.navigationBarTitle(Text(""))
		.navigationBarHidden(true)
        .sheet(
            isPresented: $viewModel.showReviewSheet,
            content: {
                if #available(iOS 16.0, *) {
                    ReviewSheetView(viewModel: viewModel)
                        .presentationDetents([.fraction(0.65), .large])
                } else {
                    ReviewSheetView(viewModel: viewModel)
                }
            }
        )
        .dinotisAlert(
          isPresent: $viewModel.isShowAlert,
          title: viewModel.alert.title,
          isError: viewModel.alert.isError,
          message: viewModel.alert.message,
          primaryButton: viewModel.alert.primaryButton,
          secondaryButton: viewModel.alert.secondaryButton
        )
	}
}

private extension ScheduleListView {
    struct TodayAgendaView: View {
        
        @ObservedObject var viewModel: ScheduleListViewModel
        
        var body: some View {
            LazyVStack {
                HStack {
                    Text(LocalizableText.scheduleTodayAgenda)
                        .font(.robotoBold(size: 16))
                        .foregroundColor(.DinotisDefault.black1)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                if !viewModel.todaysAgenda.isEmpty {
                    Section {
                            TabView {
                                ForEach(viewModel.todaysAgenda, id: \.id) { item in
                                    SessionCard(
                                        with: SessionCardModel(
                                            title: (item.meeting?.title).orEmpty(),
                                            date: DateUtils.dateFormatter((item.meeting?.startAt).orCurrentDate(), forFormat: .ddMMMMyyyy),
                                            startAt: DateUtils.dateFormatter((item.meeting?.startAt).orCurrentDate(), forFormat: .HHmm),
                                            endAt: DateUtils.dateFormatter((item.meeting?.endAt).orCurrentDate(), forFormat: .HHmm),
                                            isPrivate: (item.meeting?.isPrivate) ?? false,
                                            isVerified: (item.meeting?.user?.isVerified) ?? false,
                                            photo: (item.meeting?.user?.profilePhoto).orEmpty(),
                                            name: (item.meeting?.user?.name).orEmpty(),
                                            color: item.meeting?.background,
                                            isActive: item.meeting?.endAt.orCurrentDate() ?? Date() > Date(),
                                            collaborationCount: (item.meeting?.meetingCollaborations ?? []).count,
                                            collaborationName: (item.meeting?.meetingCollaborations ?? []).compactMap({
                                                (
                                                    $0.user?.name
                                                ).orEmpty()
                                            }).joined(separator: ", "),
                                            isAlreadyBooked: false
                                        )
                                    ) {
                                        viewModel.routeToUsertDetailSchedule(
											bookingId: item.id.orEmpty(),
                                            talentName: (item.meeting?.user?.name).orEmpty(),
                                            talentPhoto: (item.meeting?.user?.profilePhoto).orEmpty()
                                        )
                                    } visitProfile: {
                                        viewModel.routeToTalentProfile(username: (item.meeting?.user?.username).orEmpty())
                                    }
                                    .frame(width: .infinity)
                                    .padding()
                                    .background(Color.clear)
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .frame(height: UIScreen.main.bounds.width/2)
                            
                    }
                } else {
                    VStack {
                        Image.scheduleEmptyImage
                            .resizable()
                            .scaledToFit()
                            .frame(height: 175)
                            .padding()
                        
                        Text(LocalizableText.scheduleEmptyTodayAgenda)
                            .font(.robotoBold(size: 14))
                            .foregroundColor(.DinotisDefault.black1)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    struct SectionHeader: View {
        
        @ObservedObject var viewModel: ScheduleListViewModel
        
        var body: some View {
            Group {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    ScrollViewReader { reader in
                        ScrollView(.horizontal, showsIndicators: false) {
                            ZStack(alignment: .bottom) {
                                Rectangle()
                                    .frame(height: 1.5, alignment: .center)
                                    .foregroundColor(.DinotisDefault.lightPrimary)
                                
                                LazyHStack(spacing: 0) {
                                    Button {
                                        withAnimation {
                                            reader.scrollTo(0, anchor: .center)
											Task {
												viewModel.currentTab = .all

												viewModel.bookingData = []
												viewModel.takeItem = 15
												viewModel.status = ""
												await viewModel.getBookingsList(isMore: false)
											}

                                        }
                                        
                                    } label: {
                                        VStack(spacing: 25) {
                                            HStack(alignment: .center) {
                                                Spacer()
                                                Text(LocalizableText.tabAllText)
                                                    .font(.robotoBold(size: 14))
                                                    .foregroundColor(viewModel.currentTab == .all ? .DinotisDefault.black1 : .DinotisDefault.black3)
                                                Spacer()
                                            }
                                            .background(Color.clear)
                                            .padding(.horizontal)
                                            .padding(.bottom, -5)
                                            
                                            Rectangle()
                                                .frame(height: 1.5, alignment: .center)
                                                .foregroundColor(viewModel.currentTab == .all ? .DinotisDefault.primary : Color.clear)
                                                .padding([.leading], 5)
                                        }
                                    }
                                    .id(0)
                                    
                                    Button {
                                        withAnimation {

                                            reader.scrollTo(1, anchor: .center)

											Task {
												viewModel.currentTab = .waiting
												viewModel.bookingData = []
												viewModel.takeItem = 15
												viewModel.status = SessionStatus.waitingForPayment.rawValue
												await viewModel.getBookingsList(isMore: false)
											}
                                        }
                                    } label: {
                                        VStack(spacing: 25) {
                                            HStack(alignment: .center) {
                                                Spacer()
                                                Text(LocalizableText.scheduleTabWaiting)
                                                    .font(.robotoBold(size: 14))
                                                    .foregroundColor(viewModel.currentTab == .waiting ? .DinotisDefault.black1 : .DinotisDefault.black3)
                                                Spacer()
                                            }
                                            .background(Color.clear)
                                            .padding(.horizontal)
                                            .padding([.bottom], -5)
                                            
                                            Rectangle()
                                                .frame(height: 1.5, alignment: .center)
                                                .foregroundColor(viewModel.currentTab == .waiting ? .DinotisDefault.primary : Color.clear)
                                            
                                        }
                                    }
                                    .id(1)
                                    
                                    Button {
                                        withAnimation {

                                            reader.scrollTo(2, anchor: .center)

											Task {
												viewModel.currentTab = .upcoming
												viewModel.bookingData = []
												viewModel.takeItem = 15
												viewModel.status = SessionStatus.upcoming.rawValue
												await viewModel.getBookingsList(isMore: false)
											}
                                        }
                                    } label: {
                                        VStack(spacing: 25) {
                                            HStack(alignment: .center) {
                                                Spacer()
                                                Text(LocalizableText.scheduleTabUpcoming)
                                                    .font(.robotoBold(size: 14))
                                                    .foregroundColor(viewModel.currentTab == .upcoming ? .DinotisDefault.black1 : .DinotisDefault.black3)
                                                Spacer()
                                            }
                                            .background(Color.clear)
                                            .padding(.horizontal)
                                            .padding([.bottom], -5)
                                            
                                            Rectangle()
                                                .frame(height: 1.5, alignment: .center)
                                                .foregroundColor(viewModel.currentTab == .upcoming ? .DinotisDefault.primary : .clear)
                                            
                                        }
                                    }
                                    .id(2)
                                    
                                    Button {
                                        withAnimation {

                                            reader.scrollTo(3, anchor: .center)

											Task {
												viewModel.currentTab = .finished
												viewModel.bookingData = []
												viewModel.takeItem = 15
												viewModel.status = SessionStatus.done.rawValue
												await viewModel.getBookingsList(isMore: false)
											}
                                        }
                                    } label: {
                                        VStack(spacing: 25) {
                                            HStack(alignment: .center) {
                                                Spacer()
                                                Text(LocalizableText.doneLabel)
                                                    .font(.robotoBold(size: 14))
                                                    .foregroundColor(viewModel.currentTab == .finished ? .DinotisDefault.black1 : .DinotisDefault.black3)
                                                Spacer()
                                            }
                                            .background(Color.clear)
                                            .padding(.horizontal)
                                            .padding([.bottom], -5)
                                            
                                            Rectangle()
                                                .frame(height: 1.5, alignment: .center)
                                                .foregroundColor(viewModel.currentTab == .finished ? .DinotisDefault.primary : .clear)
                                                .padding([.trailing], 5)
                                            
                                        }
                                    }
                                    .id(3)
                                    
                                    Button {
                                        withAnimation {

                                            reader.scrollTo(4, anchor: .center)

											Task {
												viewModel.currentTab = .canceled
												viewModel.bookingData = []
												viewModel.takeItem = 15
												viewModel.status = SessionStatus.canceled.rawValue
												await viewModel.getBookingsList(isMore: false)
											}
                                        }
                                    } label: {
                                        VStack(spacing: 25) {
                                            HStack(alignment: .center) {
                                                Spacer()
                                                Text(LocalizableText.scheduleTabCancel)
                                                    .font(.robotoBold(size: 14))
                                                    .foregroundColor(viewModel.currentTab == .canceled ? .DinotisDefault.black1 : .DinotisDefault.black3)
                                                Spacer()
                                            }
                                            .background(Color.clear)
                                            .padding([.bottom], -5)
                                            
                                            Rectangle()
                                                .frame(height: 1.5, alignment: .center)
                                                .foregroundColor(viewModel.currentTab == .canceled ? .DinotisDefault.primary : .clear)
                                        }
                                    }
                                    .id(4)
                                }
                            }
                            .padding([.leading, .trailing, .top])
                        }
                        .onChange(of: viewModel.currentTab) { value in
                            withAnimation {
                                switch value {
                                case .all:
                                    reader.scrollTo(0, anchor: .center)
                                case .waiting:
                                    reader.scrollTo(1, anchor: .center)
                                case .upcoming:
                                    reader.scrollTo(2, anchor: .center)
                                case .finished:
                                    reader.scrollTo(3, anchor: .center)
                                case .canceled:
                                    reader.scrollTo(4, anchor: .center)
                                }
                            }
                        }
                    }
                } else {
                    ZStack(alignment: .bottom) {
                        HStack {
                            Button {
                                withAnimation {
									viewModel.currentTab = .all

									Task {
										viewModel.bookingData = []
										viewModel.takeItem = 8
										viewModel.status = ""
										await viewModel.getBookingsList(isMore: false)
									}
                                }
                            } label: {
                                VStack(spacing: 25) {
                                    HStack(alignment: .center) {
                                        Spacer()
                                        Text(LocalizableText.tabAllText)
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(viewModel.currentTab == .all ? .DinotisDefault.black1 : .DinotisDefault.black3)
                                        Spacer()
                                    }
                                    .background(Color.clear)
                                    .padding(.horizontal)
                                    .padding(.bottom, -5)
                                    
                                    Rectangle()
                                        .frame(height: 1.5, alignment: .center)
                                        .foregroundColor(viewModel.currentTab == .all ? .DinotisDefault.primary : .clear)
                                        .padding([.leading], 5)
                                }
                            }
                            .id(0)
                            
                            Button {
                                withAnimation {

									viewModel.currentTab = .waiting

									Task {

										viewModel.bookingData = []
										viewModel.takeItem = 8
										viewModel.status = SessionStatus.waitingForPayment.rawValue
										await viewModel.getBookingsList(isMore: false)
									}
                                }
                            } label: {
                                VStack(spacing: 25) {
                                    HStack(alignment: .center) {
                                        Spacer()
                                        Text(LocalizableText.scheduleTabWaiting)
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(viewModel.currentTab == .waiting ? .DinotisDefault.black1 : .DinotisDefault.black3)
                                        Spacer()
                                    }
                                    .background(Color.clear)
                                    .padding(.horizontal)
                                    .padding([.bottom], -5)
                                    
                                    Rectangle()
                                        .frame(height: 1.5, alignment: .center)
                                        .foregroundColor(viewModel.currentTab == .waiting ? .DinotisDefault.primary : .clear)
                                    
                                }
                            }
                            .id(1)
                            
                            Button {
                                withAnimation {
                                    viewModel.currentTab = .upcoming

									Task {
										viewModel.bookingData = []
										viewModel.takeItem = 8
										viewModel.status = SessionStatus.upcoming.rawValue
										await viewModel.getBookingsList(isMore: false)
									}
                                }
                            } label: {
                                VStack(spacing: 25) {
                                    HStack(alignment: .center) {
                                        Spacer()
                                        Text(LocalizableText.scheduleTabUpcoming)
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(viewModel.currentTab == .upcoming ? .DinotisDefault.black1 : .DinotisDefault.black3)
                                        Spacer()
                                    }
                                    .background(Color.clear)
                                    .padding(.horizontal)
                                    .padding([.bottom], -5)
                                    
                                    Rectangle()
                                        .frame(height: 1.5, alignment: .center)
                                        .foregroundColor(viewModel.currentTab == .upcoming ? .DinotisDefault.primary : .clear)
                                    
                                }
                            }
                            .id(2)
                            
                            Button {
                                withAnimation {
									viewModel.currentTab = .finished

									Task {

										viewModel.bookingData = []
										viewModel.takeItem = 8
										viewModel.status = SessionStatus.done.rawValue
										await viewModel.getBookingsList(isMore: false)
									}
                                }
                            } label: {
                                VStack(spacing: 25) {
                                    HStack(alignment: .center) {
                                        Spacer()
                                        Text(LocalizableText.doneLabel)
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(viewModel.currentTab == .finished ? .DinotisDefault.black1 : .DinotisDefault.black3)
                                        Spacer()
                                    }
                                    .background(Color.clear)
                                    .padding(.horizontal)
                                    .padding([.bottom], -5)
                                    
                                    Rectangle()
                                        .frame(height: 1.5, alignment: .center)
                                        .foregroundColor(viewModel.currentTab == .finished ? .DinotisDefault.primary : .clear)
                                        .padding([.trailing], 5)
                                    
                                }
                            }
                            .id(3)
                            
                            Button {
                                withAnimation {
									viewModel.currentTab = .canceled

									Task {

										viewModel.bookingData = []
										viewModel.takeItem = 8
										viewModel.status = SessionStatus.canceled.rawValue
										await viewModel.getBookingsList(isMore: false)
									}
                                }
                            } label: {
                                VStack(spacing: 25) {
                                    HStack(alignment: .center) {
                                        Spacer()
                                        Text(LocalizableText.scheduleTabCancel)
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(viewModel.currentTab == .canceled ? .DinotisDefault.black1 : .DinotisDefault.black3)
                                        Spacer()
                                    }
                                    .background(Color.clear)
                                    .padding(.horizontal)
                                    .padding([.bottom], -5)
                                    
                                    Rectangle()
                                        .frame(height: 1.5, alignment: .center)
                                        .foregroundColor(viewModel.currentTab == .canceled ? .DinotisDefault.primary : .clear)
                                        .padding([.trailing], 5)
                                }
                            }
                            .id(4)
                        }
                        .padding([.leading, .trailing, .top])
                        
                        Rectangle()
                            .frame(height: 1.5, alignment: .center)
                            .foregroundColor(.DinotisDefault.lightPrimary)
                    }
                }
            }
            .padding(.bottom, 10)
            .background(
                RoundedCorner(radius: 20, corners: [.topLeft, .topRight])
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.01), radius: 2, x: 0, y: -5)
            )
        }
    }
    
    struct SessionListView: View {
        
        @ObservedObject var viewModel: ScheduleListViewModel
        @Binding var mainTabSelection: TabRoute
        
        var body: some View {
            if viewModel.bookingData.isEmpty {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text(LocalizableText.scheduleEmptySessionTitle)
                            .font(.robotoBold(size: 20))
                            .foregroundColor(.DinotisDefault.black1)
                            .multilineTextAlignment(.center)
                        
                        Text(LocalizableText.scheduleEmptySessionDesc)
                            .font(.robotoRegular(size: 16))
                            .foregroundColor(.DinotisDefault.black3)
                            .multilineTextAlignment(.center)
                    }
                    
                    DinotisPrimaryButton(
                        text: LocalizableText.scheduleSearchSessionLabel,
                        type: .adaptiveScreen,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary) {
                            withAnimation {
                                mainTabSelection = .search
                            }
                        }
                }
                .padding()
                .padding(.bottom, 40)
            } else {
                ForEach(viewModel.bookingData, id: \.id) { item in
                    if item.id == viewModel.bookingData.last?.id {
                        LazyVStack(spacing: 15) {
                            ScheduledSessionCardView(
                                data: SessionCardModel(
                                    title: (item.meeting?.title).orEmpty(),
                                    date: DateUtils.dateFormatter((item.meeting?.startAt).orCurrentDate(), forFormat: .ddMMMyyyy),
                                    isVerified: (item.meeting?.user?.isVerified) ?? false,
                                    photo: (item.meeting?.user?.profilePhoto).orEmpty(),
                                    name: (item.meeting?.user?.name).orEmpty(),
                                    color: [""],
                                    session: (item.meetingBundle?.session).orZero(),
                                    price: (item.meeting?.price).orEmpty() == "0" ? LocalizableText.freeText : (item.meeting?.price).orEmpty().toCurrency(),
                                    isActive: item.meeting?.endedAt == nil ? true : false,
                                    type: item.meetingBundle?.id == nil ? .session : .bundling,
                                    invoiceId: item.invoiceId.orEmpty(),
                                    status: viewModel.sessionStatus(item),
                                    isAlreadyBooked: false
                                ),
                                buttonLabel: viewModel.buttonLabel(item),
                                color: viewModel.labelColor(item)) {
                                    viewModel.buttonAction(item)
                                } visitProfile: {
                                    viewModel.routeToTalentProfile(username: (item.meeting?.user?.username).orEmpty())
                                }
                                .onAppear {
                                    if item.id == viewModel.bookingData.last?.id && viewModel.nextCursor != nil {
                                        Task {
                                            viewModel.takeItem += 15
                                            await viewModel.getBookingsList(isMore: true)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            
                            HStack {
                                Spacer()
                                
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.black)
                                
                                Spacer()
                            }
                            .isHidden(!viewModel.isLoadMoreData, remove: !viewModel.isLoadMoreData)
                        }
                        .padding(.bottom, 50)
                        
                    } else {
                        ScheduledSessionCardView(
                            data: SessionCardModel(
                                title: (item.meeting?.title).orEmpty(),
                                date: DateUtils.dateFormatter((item.meeting?.startAt).orCurrentDate(), forFormat: .ddMMMyyyy),
                                isVerified: (item.meeting?.user?.isVerified) ?? false,
                                photo: (item.meeting?.user?.profilePhoto).orEmpty(),
                                name: (item.meeting?.user?.name).orEmpty(),
                                color: [""],
                                session: (item.meetingBundle?.session).orZero(),
                                price: (item.meeting?.price).orEmpty() == "0" ? LocalizableText.freeText : (item.meeting?.price).orEmpty().toCurrency(),
                                isActive: item.meeting?.endedAt == nil ? true : false,
                                type: item.meetingBundle?.id == nil ? .session : .bundling,
                                invoiceId: item.invoiceId.orEmpty(),
                                status: viewModel.sessionStatus(item),
                                isAlreadyBooked: false
                            ),
                            buttonLabel: viewModel.buttonLabel(item),
                            color: viewModel.labelColor(item)) {
                                viewModel.buttonAction(item)
                            } visitProfile: {
                                viewModel.routeToTalentProfile(username: (item.meeting?.user?.username).orEmpty())
                            }
                            .onAppear {
                                if item.id == viewModel.bookingData.last?.id && viewModel.nextCursor != nil {
                                    Task {
                                        viewModel.takeItem += 15
                                        await viewModel.getBookingsList(isMore: true)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 6)
                    }
                }
            }
        }
    }
    
    struct ReviewSheetView: View {
        @ObservedObject var viewModel: ScheduleListViewModel
        
        var body: some View {
            VStack {
                HStack {
                    Text(LocalizableText.giveReviewLabel)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.DinotisDefault.black1)
                    
                    Spacer()
                    
                    Button {
                        viewModel.showReviewSheet = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color(UIColor.systemGray4))
                    }
                }
                
                Spacer()
                
                HStack(spacing: 14) {
                    DinotisImageLoader(urlString: viewModel.reviewImage.orEmpty())
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.reviewCreatorName.orEmpty())
                            .font(.robotoMedium(size: 10))
                            .foregroundColor(.DinotisDefault.black3)
                            .lineLimit(1)
                        
                        Text(viewModel.reviewTitle.orEmpty())
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.DinotisDefault.black2)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding(.bottom)
                
                HStack(spacing: 32) {
                    ForEach(1...5, id: \.self) { index in
                        Button {
                            withAnimation {
                                viewModel.reviewRating = index
                            }
                        } label: {
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                                .foregroundColor(viewModel.reviewRating >= index ? .DinotisDefault.orange : Color(UIColor.systemGray3))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                VStack(alignment: .leading, spacing: 8) {
                    DinotisTextEditor(
                        LocalizableText.yourCommentPlaceholder,
                        label: LocalizableText.yourCommentTitle,
                        text: $viewModel.reviewMessage,
                        errorText: .constant(nil)
                    )
                }
                
                Spacer()
                
                DinotisPrimaryButton(
                    text: LocalizableText.sendReviewLabel,
                    type: .adaptiveScreen,
                    textColor: .white,
                    bgColor: (viewModel.reviewRating == 0 || !viewModel.reviewMessage.isStringContainWhitespaceAndText()) ? .DinotisDefault.lightPrimary : .DinotisDefault.primary) {
                        Task {
                            await viewModel.giveReview()
                        }
                    }
                    .disabled(viewModel.reviewRating == 0 || !viewModel.reviewMessage.isStringContainWhitespaceAndText())
            }
            .padding()
            .onDisappear {
                viewModel.reviewRating = 0
                viewModel.reviewMessage = ""
            }
        }
    }
}

struct ScheduleListView_Previews: PreviewProvider {
	static var previews: some View {
        ScheduleListView(viewModel: ScheduleListViewModel(backToRoot: {}, backToHome: {}, currentUserId: ""), mainTabSelection: .constant(.agenda))
	}
}
