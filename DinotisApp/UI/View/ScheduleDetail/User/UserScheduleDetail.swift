//
//  UserScheduleDetail.swift
//  DinotisApp
//
//  Created by Gus Adi on 24/08/21.
//

import SwiftUI
import SwiftUITrackableScrollView
import CurrencyFormatter
import SwiftUINavigation
import OneSignal

struct UserScheduleDetail: View {
    @StateObject private var streamViewModel = StreamViewModel()
    @StateObject private var participantsViewModel = ParticipantsViewModel()
    @StateObject private var streamManager = StreamManager()
    @StateObject private var speakerSettingsManager = SpeakerSettingsManager()
    @StateObject private var hostControlsManager = HostControlsManager()
    @StateObject private var speakerGridViewModel = SpeakerGridViewModel()
    @StateObject private var presentationLayoutViewModel = PresentationLayoutViewModel()
    @StateObject private var chatManager = ChatManager()

	@StateObject private var privateStreamViewModel = PrivateStreamViewModel()
	@StateObject private var privateStreamManager = PrivateStreamManager()
	@StateObject private var privateSpeakerSettingsManager = PrivateSpeakerSettingsManager()
	@StateObject private var privateSpeakerViewModel = PrivateVideoSpeakerViewModel()
    
    @State var isErrorShow = false
    
    @State var isLoading = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var detailVM = DetailBookingViewModel.shared
    @ObservedObject var userVM = UsersViewModel.shared
    @ObservedObject var bookingVm = UserBookingViewModel()
    
    @State var isGoToVideoCall = false
    
    @State var startPresented = false
    
    @State var randomId = UInt.random(in: .init(1...99999999))
    
    @State var isShowConnection = false
    
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    @ObservedObject var viewModel: ScheduleDetailViewModel
    @ObservedObject var stateObservable = StateObservable.shared
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let meetId = detailVM.data?.meeting.id {

                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.twilioLiveStream,
                        destination: {viewModel in
													TwilioGroupVideoCallView(
                                viewModel: viewModel.wrappedValue,
                                meetingId: .constant(meetId), speaker: SpeakerVideoViewModel()
                            )
                            .environmentObject(streamViewModel)
                            .environmentObject(participantsViewModel)
                            .environmentObject(streamManager)
                            .environmentObject(speakerGridViewModel)
                            .environmentObject(presentationLayoutViewModel)
                            .environmentObject(speakerSettingsManager)
                            .environmentObject(hostControlsManager)
                            .environmentObject(chatManager)
                        },
                        onNavigate: {_ in},
                        label: {
                            EmptyView()
                        }
                    )

					NavigationLink(
						unwrapping: $viewModel.route,
						case: /HomeRouting.videoCall,
						destination: {viewModel in
							PrivateVideoCallView(randomId: $randomId, meetingId: .constant(meetId), viewModel: viewModel.wrappedValue)
								.environmentObject(privateStreamViewModel)
								.environmentObject(privateStreamManager)
								.environmentObject(privateSpeakerViewModel)
								.environmentObject(privateSpeakerSettingsManager)
						},
						onNavigate: {_ in},
						label: {
							EmptyView()
						}
					)
                }
                
                ZStack(alignment: .top) {
                    Image.Dinotis.userTypeBackground
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .alert(isPresented: $detailVM.isRefreshFailed) {
                            Alert(
                                title: Text(NSLocalizedString("attention", comment: "")),
                                message: Text(NSLocalizedString("session_expired", comment: "")),
                                dismissButton: .default(Text(NSLocalizedString("return", comment: "")), action: {
                                    viewModel.backToRoot()
                                    stateObservable.userType = 0
                                    stateObservable.isVerified = ""
                                    stateObservable.refreshToken = ""
                                    stateObservable.accessToken = ""
                                    stateObservable.isAnnounceShow = false
                                    OneSignal.setExternalUserId("")
                                })
                            )
                        }
                    
                    VStack(spacing: 0) {
                        Color.white.frame(height: 20)
                            .edgesIgnoringSafeArea(.all)
                            .alert(isPresented: $userVM.isRefreshFailed) {
                                Alert(
                                    title: Text(NSLocalizedString("attention", comment: "")),
                                    message: Text(NSLocalizedString("session_expired", comment: "")),
                                    dismissButton: .default(
                                        Text(NSLocalizedString("return", comment: "")),
                                        action: {
                                            viewModel.backToRoot()
                                            stateObservable.userType = 0
                                            stateObservable.isVerified = ""
                                            stateObservable.refreshToken = ""
                                            stateObservable.accessToken = ""
                                            stateObservable.isAnnounceShow = false
                                            OneSignal.setExternalUserId("")
                                        }
                                    )
                                )
                            }
                        
                        ZStack {
                            HStack {
                                Spacer()
                                Text(NSLocalizedString("video_call_details", comment: ""))
                                    .font(Font.custom(FontManager.Montserrat.bold, size: 14))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .padding()
                            HStack {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }, label: {
                                    Image("ic-chevron-back")
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                })
                                .padding(.leading)
                                
                                Spacer()
                            }
                            
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                        .background(Color.white.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 20))
                        
                        if let detail = detailVM.data {
                            ScrollableContent(viewModel: viewModel, detailVM: detailVM, userVM: userVM, isLoading: $isLoading, action: refreshList, participantCount: participantCount(data: detail))
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
					.onChange(of: detailVM.success) { newValue in
						if newValue {

							guard let meet = detailVM.data?.meeting else {return}

							if detailVM.data?.meeting.isPrivate ?? false {
								privateStreamManager.meetingId = meet.id

								let localParticipant = PrivateLocalParticipantManager()
								let roomManager = PrivateRoomManager()

								roomManager.configure(localParticipant: localParticipant)

								let speakerVideoViewModelFactory = PrivateSpeakerVideoViewModelFactory()
								let speakersMap = SyncUsersMap()

								privateStreamManager.configure(roomManager: roomManager)
								privateStreamViewModel.configure(streamManager: privateStreamManager, speakerSettingsManager: privateSpeakerSettingsManager, meetingId: meet.id)
								privateSpeakerSettingsManager.configure(roomManager: roomManager)
								privateSpeakerViewModel.configure(roomManager: roomManager, speakersMap: speakersMap, speakerVideoViewModelFactory: speakerVideoViewModelFactory)

							} else {

								streamManager.meetingId = meet.id

								let localParticipant = LocalParticipantManager()
								let roomManager = RoomManager()
								roomManager.configure(localParticipant: localParticipant)
								let roomDocument = SyncRoomDocument()
								let userDocument = SyncUserDocument()
								let speakersMap = SyncUsersMap()
								let raisedHandsMap = SyncUsersMap()
								let viewersMap = SyncUsersMap()
								let speakerVideoViewModelFactory = SpeakerVideoViewModelFactory()
								let syncManager = SyncManager(speakersMap: speakersMap, viewersMap: viewersMap, raisedHandsMap: raisedHandsMap, userDocument: userDocument, roomDocument: roomDocument)
								participantsViewModel.configure(streamManager: streamManager, roomManager: roomManager, speakersMap: speakersMap, viewersMap: viewersMap, raisedHandsMap: raisedHandsMap)
								streamManager.configure(roomManager: roomManager, playerManager: PlayerManager(), syncManager: syncManager, chatManager: chatManager)
								streamViewModel.configure(streamManager: streamManager, speakerSettingsManager: speakerSettingsManager, userDocument: userDocument, meetingId: meet.id, roomDocument: roomDocument)
								speakerSettingsManager.configure(roomManager: roomManager)
								hostControlsManager.configure(roomManager: roomManager)
								speakerVideoViewModelFactory.configure(meetingId: meet.id, speakersMap: speakersMap)
								speakerGridViewModel.configure(roomManager: roomManager, speakersMap: speakersMap, speakerVideoViewModelFactory: speakerVideoViewModelFactory)
								presentationLayoutViewModel.configure(roomManager: roomManager, speakersMap: speakersMap, speakerVideoViewModelFactory: speakerVideoViewModelFactory)
							}
						}
                    }
                    
                    BottomView(viewModel: viewModel, detailVM: detailVM, startPresented: $startPresented, isPaid: isPaid)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            detailVM.getDetailBookings(id: viewModel.bookingId)
                            bookingVm.getBookings()
                            userVM.getUsers()
                            stateObservable.spotlightedIdentity = ""
                        }
                }
                
                ZStack {
                    Color.black.opacity(viewModel.isShowingRules ? 0.4 : 0)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                viewModel.isShowingRules = false
                            }
                        }
                    
                    VStack {
                        Spacer()
                        
                        VStack {
                            Text(LocaleText.detailScheduleMeetingRulesTitle)
                                .font(.montserratBold(size: 14))
                                .foregroundColor(.black)
                                .padding()
                            
                            HTMLStringView(htmlContent: viewModel.HTMLContent)
                                .frame(height: geo.size.height/2)
                                .padding([.horizontal, .bottom])
                        }
                        .background(Color.white)
                        .clipShape(RoundedCorner(radius: 18, corners: [.topLeft, .topRight]))
                        .onAppear {
                            viewModel.getMeetingRules()
                        }
                        
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .offset(y: viewModel.isShowingRules ? .zero : geo.size.height+100)
                }
                
                LoadingView(isAnimating: .constant(true))
                    .isHidden(
                        (detailVM.isLoading && detailVM.data == nil) ?
                        false : true,
                        remove: (detailVM.isLoading && detailVM.data == nil) ?
                        false : true
                    )
            }
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
            .onDisappear(perform: {
                startPresented = false
            })
			.dinotisSheet(isPresented: $startPresented, fraction: 0.7, content: {
				VStack(spacing: 15) {
					Image("img-popout")
						.resizable()
						.scaledToFit()
						.frame(height: 200)

					VStack(spacing: 35) {
						VStack(spacing: 10) {
							Text(NSLocalizedString("start_meeting_alert", comment: ""))
								.font(Font.custom(FontManager.Montserrat.bold, size: 14))
								.foregroundColor(.black)

							Text(NSLocalizedString("talent_start_call", comment: ""))
								.font(Font.custom(FontManager.Montserrat.regular, size: 12))
								.foregroundColor(.black)
								.multilineTextAlignment(.center)
						}

						HStack(spacing: 15) {
							Button(action: {
								startPresented.toggle()
							}, label: {
								HStack {
									Spacer()
									Text(NSLocalizedString("cancel", comment: ""))
										.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
										.foregroundColor(.black)
									Spacer()
								}
								.padding()
								.background(Color("btn-color-1"))
								.cornerRadius(8)
								.overlay(
									RoundedRectangle(cornerRadius: 8)
										.stroke(Color("btn-stroke-1"), lineWidth: 1.0)
								)
							})

							Button(action: {

								guard let meet = detailVM.data?.meeting else { return }

								if (detailVM.data?.meeting.slots).orZero() > 1 {
									self.viewModel.routeToTwilioLiveStream(meeting: meet)
								} else {
									self.viewModel.routeToVideoCall(meeting: meet)
								}
							}, label: {
								HStack {
									Spacer()
									Text(NSLocalizedString("start_now", comment: ""))
										.font(Font.custom(FontManager.Montserrat.semibold, size: 12))
										.foregroundColor(.white)
									Spacer()
								}
								.padding()
								.background(Color("btn-stroke-1"))
								.cornerRadius(8)
							})
							.onAppear {
								isGoToVideoCall = false
								viewModel.onAppearView()
								StateObservable.shared.cameraPositionUsed = .front
								StateObservable.shared.twilioRole = ""
								StateObservable.shared.twilioUserIdentity = ""
								StateObservable.shared.twilioAccessToken = ""
							}
						}
					}
				}
			})
        }
    }
    
    private func isPaid() -> Bool {
        if let dataBooking = bookingVm.data?.data, let detailData = detailVM.data?.meeting {
            for book in dataBooking where book.id == detailData.id {
                return book.bookingPayment.paidAt != nil
            }
        }
        
        return false
    }
    
    private func participantCount(data: DetailBooking) -> Int {
        (data.meeting.bookings?.filter({ items in items.bookingPayment.paidAt != nil }).count).orZero()
    }
    
    func refreshList() {
        detailVM.getDetailBookings(id: viewModel.bookingId)
    }
}

private extension UserScheduleDetail {
    
    struct ScrollableContent: View {
        
        @ObservedObject var viewModel: ScheduleDetailViewModel
        @ObservedObject var detailVM: DetailBookingViewModel
        @ObservedObject var userVM: UsersViewModel
        @Binding var isLoading: Bool
        var action: (() -> Void)
        var participantCount: Int
        
        var body: some View {
            RefreshableScrollView(action: action) {
                if isLoading {
                    ActivityIndicator(isAnimating: $isLoading, color: .black, style: .medium)
                        .padding(.top)
                }
                
                if let detail = detailVM.data?.meeting, let bookingPay = detailVM.data?.bookingPayment {
                    VStack {
                        Text(LocaleText.detailScheduleStepTitle)
                            .font(.montserratBold(size: 12))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 3) {
                            VStack(alignment: .leading) {
                                HStack(spacing: 3) {
                                    HStack(spacing: 3) {
                                        
                                        (bookingPay.paidAt != nil ? Image.Dinotis.stepCheckmark : Image.Dinotis.stepOne)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 35)
                                        
                                        Rectangle()
                                            .foregroundColor(bookingPay.paidAt != nil ? .primaryViolet : Color(.systemGray4))
                                            .frame(height: 2)
                                        
                                    }
                                    
                                    HStack(spacing: 3) {
                                        
                                        (bookingPay.paidAt != nil ? Image.Dinotis.stepCheckmark : Image.Dinotis.stepTwo)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 35)
                                        
                                        Rectangle()
                                            .foregroundColor(bookingPay.paidAt != nil ? .primaryViolet : Color(.systemGray4))
                                            .frame(height: 2)
                                        
                                    }
                                    
                                    HStack(spacing: 3) {
                                        
                                        (
                                            detail.startedAt != nil ||
                                            detail.startAt.orEmpty().toDate(format: .utcV2).orCurrentDate() <= Date() ?
                                            Image.Dinotis.stepCheckmark :
                                                Image.Dinotis.stepThree
                                        )
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 35)
                                        
                                        Rectangle()
                                            .foregroundColor(
                                                detail.startedAt != nil ||
                                                detail.startAt.orEmpty().toDate(format: .utcV2).orCurrentDate() <= Date() ?
                                                    .primaryViolet :
                                                    Color(.systemGray4)
                                            )
                                            .frame(height: 2)
                                        
                                    }
                                    
                                    HStack(spacing: 3) {
                                        
                                        (detail.endedAt != nil ? Image.Dinotis.stepCheckmark : Image.Dinotis.stepFour)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 35)
                                    }
                                }
                                .padding(.horizontal, 10)
                                
                                HStack {
                                    VStack(spacing: 6) {
                                        Text(LocaleText.detailScheduleStepOne)
                                            .font(.montserratSemiBold(size: 10))
                                            .foregroundColor(bookingPay.paidAt != nil ? .primaryViolet : Color(.systemGray4))
                                        
                                        Text((bookingPay.paidAt.orEmpty().toDate(format: .utcV2)?.toString(format: .ddMMyyyyHHmm)).orEmpty())
                                            .font(.montserratRegular(size: 10))
                                            .foregroundColor(.black)
                                    }
                                    .multilineTextAlignment(.center)
                                    .frame(width: 55)
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 6) {
                                        Text(LocaleText.detailScheduleStepTwo)
                                            .font(.montserratSemiBold(size: 10))
                                            .foregroundColor(bookingPay.paidAt != nil ? .primaryViolet : Color(.systemGray4))
                                        
                                        Text((bookingPay.paidAt.orEmpty().toDate(format: .utcV2)?.toString(format: .ddMMyyyyHHmm)).orEmpty())
                                            .font(.montserratRegular(size: 10))
                                            .foregroundColor(.black)
                                    }
                                    .multilineTextAlignment(.center)
                                    .frame(width: 55)
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 6) {
                                        Text(LocaleText.detailScheduleStepThree)
                                            .font(.montserratSemiBold(size: 10))
                                            .foregroundColor(
                                                detail.startedAt != nil ||
                                                detail.startAt.orEmpty().toDate(format: .utcV2).orCurrentDate() <= Date() ?
                                                    .primaryViolet :
                                                    Color(.systemGray4)
                                            )
                                        
                                        Text(
                                            (detail.startedAt.orEmpty().toDate(format: .utcV2)?.toString(format: .ddMMyyyyHHmm)).orEmpty()
                                        )
                                        .font(.montserratRegular(size: 10))
                                        .foregroundColor(.black)
                                    }
                                    .multilineTextAlignment(.center)
                                    .frame(width: 55)
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 6) {
                                        Text(LocaleText.detailScheduleStepFour)
                                            .font(.montserratSemiBold(size: 10))
                                            .foregroundColor(detail.endedAt != nil ? .primaryViolet : Color(.systemGray4))
                                        
                                        Text((detail.endedAt.orEmpty().toDate(format: .utcV2)?.toString(format: .ddMMyyyyHHmm)).orEmpty())
                                            .font(.montserratRegular(size: 10))
                                            .foregroundColor(.black)
                                    }
                                    .multilineTextAlignment(.center)
                                    .frame(width: 55)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.white)
                            .shadow(color: Color("dinotis-shadow-1").opacity(0.08), radius: 10, x: 0, y: 0)
                    )
                    .padding([.top, .horizontal])
                }
                
                Button {
                    withAnimation(.spring()) {
                        viewModel.isShowingRules.toggle()
                    }
                    
                } label: {
                    HStack {
                        Text(LocaleText.detailScheduleMeetingRulesTitle)
                            .font(.montserratMedium(size: 14))
                            .foregroundColor(.primaryViolet)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 10)
                            .foregroundColor(.primaryViolet)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.secondaryViolet))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primaryViolet, lineWidth: 1))
                    .padding(.top, 10)
                    .padding(.horizontal)
                }
                
                
                VStack(alignment: .leading) {
                    HStack(spacing: 15) {
                        Image("ic-video-conf")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 35)
                        
                        Spacer()
                        
                        if detailVM.data?.meeting.endedAt != nil {
                            Text(NSLocalizedString("ended_meeting_card_label", comment: ""))
                                .font(.custom(FontManager.Montserrat.regular, size: 12))
                                .foregroundColor(.black)
                                .padding(.vertical, 3)
                                .padding(.horizontal, 8)
                                .background(Color(.systemGray5))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 10)
                    
                    VStack(alignment:.leading, spacing: 5) {
                        Text(detailVM.data?.meeting.title ?? "")
                            .font(Font.custom(FontManager.Montserrat.bold, size: 14))
                            .foregroundColor(.black)
                        
                        Text(detailVM.data?.meeting.meetingDescription ?? "")
                            .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                            .foregroundColor(.black)
                            .padding(.bottom, 10)
                    }
                    
                    HStack(spacing: 10) {
                        Image("ic-calendar")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 18)
                        
                        if let dateStart = (detailVM.data?.meeting.startAt?.toDate(format: .utcV2)).orCurrentDate() {
                            Text(dateStart.toString(format: .EEEEddMMMMyyyy))
                                .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                .foregroundColor(.black)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        Image("ic-clock")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 18)
                        
                        if let timeStart = (detailVM.data?.meeting.startAt?.toDate(format: .utcV2)).orCurrentDate(),
                           let timeEnd = (detailVM.data?.meeting.endAt?.toDate(format: .utcV2)).orCurrentDate() {
                            Text("\(timeStart.toString(format: .HHmm)) - \(timeEnd.toString(format: .HHmm))")
                                .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                .foregroundColor(.black)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 10) {
                            Image("ic-people-circle")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 18)
                            
                            if let data = detailVM.data {
                                Text("\(String.init(participantCount))/\(String.init(data.meeting.slots.orZero())) \(NSLocalizedString("participant", comment: ""))")
                                    .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                    .foregroundColor(.black)
                                
                                if data.meeting.slots.orZero() > 1 && !(data.meeting.isLiveStreaming ?? false) {
                                    Text(NSLocalizedString("group", comment: ""))
                                        .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                        .foregroundColor(.black)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal)
                                        .background(Color("btn-color-1"))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color("btn-stroke-1"), lineWidth: 1.0)
                                        )
                                    
                                } else if data.meeting.isLiveStreaming ?? false {
                                    Text(LocaleText.liveStreamText)
                                        .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                        .foregroundColor(.black)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal)
                                        .background(Color("btn-color-1"))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color("btn-stroke-1"), lineWidth: 1.0)
                                        )
                                } else {
                                    Text(NSLocalizedString("private", comment: ""))
                                        .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                        .foregroundColor(.black)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal)
                                        .background(Color("btn-color-1"))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color("btn-stroke-1"), lineWidth: 1.0)
                                        )
                                }
                            }
                        }
                    }
                    .valueChanged(value: detailVM.isLoading) { value in
                        DispatchQueue.main.async {
                            withAnimation(.spring()) {
                                self.isLoading = value
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Capsule()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                            .opacity(0.2)
                        
                        Text(LocaleText.generalParticipant)
                            .font(.montserratBold(size: 12))
                            .foregroundColor(.black)
                        
                        if let detailedData = detailVM.data?.meeting.bookings?.reversed() {
                            ForEach(detailedData.filter({ value in
                                value.bookingPayment.failedAt == nil &&
                                value.bookingPayment.paidAt != nil
                            }).prefix(4), id: \.id) { item  in
                                VStack {
                                    HStack {
                                        ProfileImageContainer(
                                            profilePhoto: .constant(item.user.profilePhoto),
                                            name: .constant(item.user.name),
                                            width: 40,
                                            height: 40
                                        )
                                        
                                        Text(item.user.name ?? "")
                                            .font(Font.custom(FontManager.Montserrat.semibold, size: 14))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        if let first = userVM.data?.id, let user = item.user.id {
                                            if user == first {
                                                Text(NSLocalizedString("me", comment: ""))
                                                    .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                                    .foregroundColor(.black)
                                                    .padding(.vertical, 5)
                                                    .padding(.horizontal)
                                                    .background(Color("btn-color-1"))
                                                    .clipShape(Capsule())
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(Color("btn-stroke-1"), lineWidth: 1.0)
                                                    )
                                            }
                                        }
                                    }
                                    
                                    if let last = detailedData.last?.id {
                                        if item.id != last {
                                            Capsule()
                                                .frame(height: 1)
                                                .foregroundColor(.gray)
                                                .opacity(0.2)
                                        }
                                    }
                                }
                            }
                            
                            if detailedData.count > 4 {
                                Text(LocaleText.andMoreParticipant(detailedData.count-4))
                                    .font(.montserratBold(size: 12))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color("dinotis-shadow-1").opacity(0.08), radius: 10, x: 0, y: 0)
                .padding(.top, 10)
                .padding([.bottom, .horizontal])
                
                Button(action: {
                    if let waurl = URL(string: "https://wa.me/6281318506068") {
                        if UIApplication.shared.canOpenURL(waurl) {
                            UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
                        }
                    }
                }, label: {
                    HStack {
                        Image("whatsapp-img")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        
                        HStack(spacing: 5) {
                            Text(NSLocalizedString("need_help", comment: "")).font(.custom(FontManager.Montserrat.regular, size: 12)).foregroundColor(.black).underline()
                            +
                            Text(NSLocalizedString("contact_us", comment: "")).font(.custom(FontManager.Montserrat.bold, size: 12)).foregroundColor(.black).underline()
                        }
                        
                        Spacer()
                        
                        Image("chevron-left-circle")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 0)
                    )
                    .padding(.horizontal)
                })
                .padding(.bottom, 90)
            }
        }
    }
    
    struct BottomView: View {
        
        @ObservedObject var viewModel: ScheduleDetailViewModel
        @ObservedObject var detailVM: DetailBookingViewModel
        @Binding var startPresented: Bool
        var isPaid: (() -> Bool)
        
        var body: some View {
            VStack(spacing: 0) {
                Spacer()
                
                HStack {
                    HStack(spacing: 10) {
                        Image.Dinotis.coinIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 15)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            if isPaid() {
                                Text(NSLocalizedString("payment_successful", comment: ""))
                                    .font(Font.custom(FontManager.Montserrat.regular, size: 12))
                                    .foregroundColor(.black)
                            }
                            
                            if detailVM.data?.meeting.price == "0" {
                                Text(NSLocalizedString("free_text", comment: ""))
                                    .font(.montserratBold(size: 14))
                                    .foregroundColor(.primaryViolet)
                            } else {
                                Text((detailVM.data?.meeting.price).orEmpty().toPriceFormat())
                                    .font(.montserratBold(size: 14))
                                    .foregroundColor(.primaryViolet)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    
                    Spacer()
                    
                    if detailVM.data?.meeting.endedAt == nil {
                        Button(action: {
                            startPresented.toggle()
                        }, label: {
                            HStack {
                                Text(NSLocalizedString("start_now", comment: ""))
                                    .font(Font.custom(FontManager.Montserrat.semibold, size: 12))
                                    .foregroundColor((detailVM.data?.meeting.startAt).orEmpty().toDate(format: .utcV2).orCurrentDate().addingTimeInterval(-300) > Date() ? .black : .white)
                                    .padding(10)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 5)
                            }
                            .background((detailVM.data?.meeting.startAt).orEmpty().toDate(format: .utcV2).orCurrentDate().addingTimeInterval(-300) > Date() ? Color(.systemGray5) : Color("btn-stroke-1"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        })
                        .disabled((detailVM.data?.meeting.startAt).orEmpty().toDate(format: .utcV2).orCurrentDate().addingTimeInterval(-300) > Date())
                    }
                }
                .padding()
                .background(Color.white)
                
                Color.white
                    .frame(height: 10)
                
            }
        }
    }
}
