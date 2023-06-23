//
//  TwilioLiveStreamView.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import SwiftUI
import SwiftUINavigation
import DinotisData
import DinotisDesignSystem

struct TwilioGroupVideoCallView: View {
    
    @ObservedObject var viewModel: TwilioLiveStreamViewModel
    @EnvironmentObject var streamViewModel: StreamViewModel
    @EnvironmentObject var streamManager: StreamManager
    @EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var participantsViewModel: ParticipantsViewModel
    @EnvironmentObject var speakerGridViewModel: SpeakerGridViewModel
    @EnvironmentObject var presentationLayoutViewModel: PresentationLayoutViewModel
    @EnvironmentObject var hostControlsManager: HostControlsManager
    
    @Binding var meetingId: String
    
    var speaker: SpeakerVideoViewModel
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private let spacing: CGFloat = 18
    
    private var isPortraitOrientation: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    NavigationLink(
                        unwrapping: $viewModel.route,
                        case: /HomeRouting.afterCall,
                        destination: { viewModel in
                            AfterCallView(viewModel: viewModel.wrappedValue)
                        },
                        onNavigate: {_ in},
                        label: {
                            EmptyView()
                        }
                    )
                    .alert(item: $streamViewModel.alertIdentifier) { alertIdentifier in
                        switch alertIdentifier {
                        case .error:
                            return Alert(error: streamViewModel.error) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        case .receivedSpeakerInvite:
                            return Alert(
                                title: Text(LocaleText.receivedSpeakerInviteTitle),
                                message: Text(LocaleText.receivedSpeakerInviteMessage),
                                primaryButton: .default(Text(LocaleText.joinNow)) {
                                    streamManager.changeRole(to: "speaker", meetingId: viewModel.meeting.id.orEmpty())
                                    streamViewModel.isHandRaised = false
                                },
                                secondaryButton: .destructive(Text(LocaleText.neverMind)) {
                                    streamViewModel.isHandRaised = false
                                }
                            )
                        case .speakerMovedToViewersByHost:
                            return Alert(
                                title: Text(LocaleText.speakerMovedToViewersByHostTitle),
                                message: Text(LocaleText.speakerMovedToViewersByHostMessage),
                                dismissButton: .default(Text(LocaleText.okText))
                            )
                        case .streamEndedByHost:
                            return Alert(
                                title: Text(LocaleText.streamEndedByHostTitle),
                                message: Text(LocaleText.streamEndedByHostMessage),
                                dismissButton: .default(Text(LocaleText.okText)) {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            )
                        case .streamWillEndIfHostLeaves:
                            return Alert(
                                title: Text(LocaleText.streamWillEndIfHostLeavesTitle),
                                message: Text(LocaleText.streamWillEndIfHostLeavesMessage),
                                primaryButton: .destructive(Text(LocaleText.endEvent)) {
                                    viewModel.routeToAfterCall()
                                },
                                secondaryButton: .cancel(Text(LocaleText.neverMind))
                            )
                        case .viewerConnected:
                            return Alert(
                                title: Text(LocaleText.welcome),
                                message: Text(LocaleText.viewerConnectedMessage),
                                dismissButton: .default(Text(LocaleText.gotIt))
                            )
                        case .mutedByHost:
                            return Alert(
                                title: Text(streamViewModel.isAudioLocked ? LocaleText.mutedLockByHostTitle : LocaleText.mutedByHostTitle),
                                message: Text(streamViewModel.isAudioLocked ? LocaleText.mutedLockByHostMessage : LocaleText.mutedByHostMessage),
                                dismissButton: .default(Text(LocaleText.okText))
                            )
                        case .unlockedMuteByHost:
                            return Alert(
                                title: Text(LocaleText.unlockedMuteByHostTitle),
                                message: Text(LocaleText.unlockedMuteByHostMessage),
                                dismissButton: .default(Text(LocaleText.okText))
                            )
                        case .removeAllParticipant:
                            return Alert(
                                title: Text(LocaleText.moveAllSpeakerTitle),
                                message: Text(LocaleText.moveAllSpeakerMessage),
                                primaryButton: .default(Text(LocaleText.okText)) {
                                    hostControlsManager.moveAllToViewer(on: viewModel.meeting.id.orEmpty())
                                },
                                secondaryButton: .cancel(Text(LocaleText.cancelText))
                            )
                        }
                    }

                    VStack {
                        Group {
                            if viewModel.isShowingToolbar {
                                HStack {
                                    HStack(spacing: 4) {
                                        Image.videoCallClockWhiteIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 24)
                                        
                                        Text(viewModel.stringTime)
                                            .font(.robotoBold(size: 12))
                                    }
                                    .foregroundColor(viewModel.isNearbyEnd ? .white : .primaryRed)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(viewModel.isNearbyEnd ? Color.white : Color.primaryRed, lineWidth: 1)
                                    )
                                    
                                    Spacer()
                                    
                                    switch viewModel.state.twilioRole {
                                    case "host", "speaker":
                                        Button {
                                            withAnimation(.spring()) {
                                                viewModel.isSwitched.toggle()
                                            }
                                        } label: {
                                            Image.videoCallFlipCameraWhiteIcon
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 32)
                                        }

                                        
                                    default:
                                        HStack(spacing: 8) {
                                            Image.videoCallLiveWhiteIcon
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 24)
                                            
                                            Text(LocalizableText.liveText)
                                                .font(.robotoBold(size: 12))
                                        }
                                        .padding(.leading, 6)
                                        .padding(.trailing, 12)
                                        .padding(.vertical, 2)
                                        .background(Color.DinotisDefault.red)
                                        .cornerRadius(68)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)
                                .onChange(of: viewModel.isMeetingForceEnd) { val in
                                    if val {
                                        viewModel.deleteStream {
                                            streamManager.disconnect()
                                            viewModel.routeToAfterCall()
                                        }
                                    }
                                }
                            }
                        }
                        .alert(isPresented: $viewModel.isShowingCloseAlert) {
                            switch viewModel.state.twilioRole {
                            case "viewer", "speaker":
                                return Alert(
                                    title: Text(LocaleText.attention),
                                    message: Text(LocaleText.sureEndCallSubtitle),
                                    primaryButton: .default(
                                        Text(LocaleText.okText),
                                        action: {
                                            if viewModel.state.twilioRole == "speaker" && viewModel.state.userType == 2 {
                                                viewModel.deleteStream {
                                                    DispatchQueue.main.async {
                                                        streamManager.disconnect()
                                                        viewModel.routeToAfterCall()
                                                    }
                                                }
                                            } else {
                                                DispatchQueue.main.async {
                                                    streamManager.disconnect()
                                                    viewModel.routeToAfterCall()
                                                }
                                            }
                                        }
                                    ),
                                    secondaryButton: .cancel(Text(LocaleText.cancelText), action: {
                                        speakerGridViewModel.isEnd = false
                                    })
                                )
                            default:
                                return Alert(
                                    title: Text(LocaleText.attention),
                                    message: Text(LocaleText.sureEndCallSubtitle),
                                    primaryButton: .default(
                                        Text(LocaleText.okText),
                                        action: {
                                            if viewModel.state.twilioRole == "speaker" && viewModel.state.userType == 2 {
                                                viewModel.deleteStream {
                                                    DispatchQueue.main.async {
                                                        streamManager.disconnect()
                                                        viewModel.routeToAfterCall()
                                                    }
                                                }
                                            } else {
                                                DispatchQueue.main.async {
                                                    streamManager.disconnect()
                                                    viewModel.routeToAfterCall()
                                                }
                                            }
                                        }
                                    ),
                                    secondaryButton: .cancel(Text(LocaleText.cancelText), action: {
                                        speakerGridViewModel.isEnd = false
                                    })
                                )
                            }
                        }

                        VStack {

                            HStack(spacing: 0) {
                                switch viewModel.state.twilioRole {
                                case "host", "speaker":
                                    SpeakerGridView(
                                        speaker: speaker,
                                        spacing: spacing,
                                        role: viewModel.state.twilioRole,
                                        isShowName: viewModel.isShowingToolbar
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.isShowingToolbar.toggle()
                                        }
                                    }
                                case "viewer":
                                    if streamManager.containHost {
                                        SwiftUIPlayerView(player: $streamManager.player)
                                            .onTapGesture {
                                                withAnimation {
                                                    viewModel.isShowingToolbar.toggle()
                                                }
                                            }
                                    } else {
                                        VStack(spacing: 15) {
                                            Spacer()
                                            
                                            LottieView(name: "waiting-talent", loopMode: .loop)
                                                .scaledToFit()
                                                .frame(height: geo.size.height/4)
                                            
                                            Text("Menunggu Kreator Untuk Bergabung...")
                                                .font(.robotoBold(size: 22))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                            
                                            Text("Kalau bosan menunggu, kamu bisa menghitung ada berapa logo DINOTIS yang terdapat di halaman ini 😉")
                                                .font(.robotoRegular(size: 14))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation {
                                                viewModel.isShowingToolbar.toggle()
                                            }
                                        }
                                    }
                                        
                                default:
                                    VStack {
                                        Spacer()
                                    }
                                }
                            }

                        }
                        .onChange(of: viewModel.isShowNearEndAlert, perform: { newValue in
                            if newValue {
                                viewModel.isShowed = true
                            }
                        })
                        
                        if streamManager.state != .connecting {
                            if viewModel.isShowingToolbar {
                                BottomToolbar(
                                    speakerSettingsManager: speakerSettingsManager,
                                    viewModel: viewModel,
                                    closeLive: {
                                        DispatchQueue.main.async {
                                            streamManager.disconnect()
                                            viewModel.routeToAfterCall()
                                        }
                                    }
                                )
                                .padding()
                                .padding(.bottom, isPortraitOrientation ? 18 : 0)
                                .background(Color.white)
                                .edgesIgnoringSafeArea(.horizontal)
                            }
                        }
                    }

                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                if  viewModel.isShowingAbout {
                                    viewModel.isShowingAbout.toggle()
                                }
                            }
                        }
                        .opacity(viewModel.isShowingAbout || viewModel.isShowed ? 1 : 0)

                    ZStack {
                        DetailMeetingView(meeting: viewModel.meeting, viewModel: viewModel)
                    }
                    .onTapGesture {
                        withAnimation {
                            viewModel.isShowingAbout.toggle()
                        }
                    }
                    .opacity(viewModel.isShowingAbout ? 1 : 0)

                    ZStack {
                        VStack(spacing: 20) {
                            LottieView(name: "close-to-end", loopMode: .loop)
                                .scaledToFit()
                                .frame(height: geo.size.width/2)

                            VStack(spacing: 10) {
                                Text(LocaleText.fiveMinuteEndTitle)
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)

                                Text(StateObservable.shared.twilioRole == "viewer" || StateObservable.shared.twilioRole == "speaker" ? LocaleText.fiveMinEndViewerMessage : LocaleText.fiveMinuteEndSubtitle)
                                    .font(.robotoRegular(size: 14))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                            }

                            Button {
                                withAnimation {
                                    viewModel.isShowed.toggle()
                                }

                            } label: {
                                Text(LocaleText.okText)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 50)
                                    .padding(.vertical, 15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .foregroundColor(.DinotisDefault.primary)
                                    )
                            }
                            .padding(.top, 10)

                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(.white)
                        )
                        .padding()
                    }
                    .frame(height: geo.size.height)
                    .opacity(viewModel.isShowed ? 1 : 0)

                    VStack {
                        Text(LocaleText.allParticipantIsMuted)
                            .foregroundColor(.white)
                            .font(.robotoMedium(size: 12))
                            .padding()
                            .background(
                                Capsule()
                                    .foregroundColor(.DinotisDefault.primary)
                            )
                            .onChange(of: viewModel.isMuteOnlyUser) { newValue in
                                if newValue {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation {
                                            viewModel.isMuteOnlyUser = false
                                        }
                                    }
                                }

                            }

                        Spacer()
                    }
                    .padding()
                    .opacity(viewModel.isMuteOnlyUser ? 1 : 0)
                }
                .edgesIgnoringSafeArea(.bottom)
                
                Group {
                    if streamManager.state == .connecting {
                        ProgressHUD(
                            streamManager: _streamManager,
                            title: LocaleText.joiningLoadingEvent,
                            description: LocaleText.loadingReminder,
                            geo: geo,
                            closeLive: {
                                if viewModel.state.twilioRole == "speaker" && viewModel.state.userType == 2 {
                                    viewModel.deleteStream {
                                        DispatchQueue.main.async {
                                            streamManager.disconnect()
                                            viewModel.routeToAfterCall()
                                        }
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        streamManager.disconnect()
                                        viewModel.routeToAfterCall()
                                    }
                                }
                            }
                        )
                    } else if streamManager.state == .changingRole || streamManager.isLoading || viewModel.isLoading {
                        ProgressHUD(
                            streamManager: _streamManager,
                            title: LocaleText.loadingText,
                            geo: geo,
                            closeLive: {}
                        )
                    } else if hostControlsManager.loadingState == .removingAllParticipant && hostControlsManager.isLoading {
                        ProgressHUD(
                            streamManager: _streamManager,
                            title: LocaleText.moveAllParticipantsLoading,
                            geo: geo,
                            closeLive: {}
                        )
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowQuestionBox, content: {
                if #available(iOS 16.0, *) {
                    LazyVStack(spacing: 15) {
                        LazyVStack(spacing: 10) {
                            Text(LocaleText.groupCallQuestionBox)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.white)

                            Text(LocaleText.groupCallQuestionSub)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }

                        TextEditor(text: $viewModel.questionText)
                            .background(Color.white)
                            .font(.robotoRegular(size: 12))
                            .frame(height: geo.size.width > geo.size.height ? geo.size.height/2 : geo.size.height/4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke((UIApplication.shared.windows.first?.overrideUserInterfaceStyle ?? .dark) == .dark ? Color.white : Color(.systemGray3), lineWidth: 1)
                            )
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Button {
                            viewModel.postQuestion(meetingId: viewModel.meeting.id.orEmpty())

                        } label: {
                            HStack {
                                Spacer()

                                if viewModel.isLoadingQuestion {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .accentColor(.white)
                                } else {
                                    Text(LocaleText.sendText)
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(
                                            viewModel.questionText.isEmpty || !viewModel.questionText.isStringContainWhitespaceAndText() ? Color(.systemGray2) : .white
                                        )
                                }

                                Spacer()
                            }
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(
                                        viewModel.questionText.isEmpty || !viewModel.questionText.isStringContainWhitespaceAndText() ? Color(.systemGray5) : .DinotisDefault.primary
                                    )
                            )
                        }
                        .disabled(viewModel.questionText.isEmpty || !viewModel.questionText.isStringContainWhitespaceAndText())

                    }
                        .padding()
                        .padding(.vertical)
                        .presentationDetents([.fraction(0.6), .large])
                } else {
                    LazyVStack(spacing: 15) {
                        LazyVStack(spacing: 10) {
                            Text(LocaleText.groupCallQuestionBox)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(.white)

                            Text(LocaleText.groupCallQuestionSub)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }

                        TextEditor(text: $viewModel.questionText)
                            .background(Color.white)
                            .font(.robotoRegular(size: 12))
                            .frame(height: geo.size.width > geo.size.height ? geo.size.height/2 : geo.size.height/4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke((UIApplication.shared.windows.first?.overrideUserInterfaceStyle ?? .dark) == .dark ? Color.white : Color(.systemGray3), lineWidth: 1)
                            )
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Button {
                            viewModel.postQuestion(meetingId: viewModel.meeting.id.orEmpty())

                        } label: {
                            HStack {
                                Spacer()

                                if viewModel.isLoadingQuestion {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .accentColor(.white)
                                } else {
                                    Text(LocaleText.sendText)
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(
                                            viewModel.questionText.isEmpty || !viewModel.questionText.isStringContainWhitespaceAndText() ? Color(.systemGray2) : .white
                                        )
                                }

                                Spacer()
                            }
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(
                                        viewModel.questionText.isEmpty || !viewModel.questionText.isStringContainWhitespaceAndText() ? Color(.systemGray5) : .DinotisDefault.primary
                                    )
                            )
                        }
                        .disabled(viewModel.questionText.isEmpty || !viewModel.questionText.isStringContainWhitespaceAndText())

                    }
                        .padding()
                        .padding(.vertical)
                }

            })
            .sheet(isPresented: $viewModel.showingMoreMenu, content: {
                if #available(iOS 16.0, *) {
                    MoreMenuItems(viewModel: viewModel)
                        .padding()
                        .padding(.vertical)
                        .presentationDetents([.fraction(viewModel.state.twilioRole == "host" ? 0.35 : 0.25), .large])
                } else {
                    MoreMenuItems(viewModel: viewModel)
                        .padding()
                        .padding(.vertical)
                }

            })
            .sheet(isPresented: $viewModel.showSetting, content: {
                if #available(iOS 16.0, *) {
                    VideoSettingView(viewModel: viewModel)
                        .padding()
                        .padding(.vertical)
                        .presentationDetents([.fraction(0.25), .large])
                } else {
                    VideoSettingView(viewModel: viewModel)
                        .padding()
                        .padding(.vertical)
                }

            })
            .sheet(isPresented: $viewModel.isShowingParticipants) {
                AboutCallBottomSheet(viewModel: participantsViewModel, twilioLiveVM: viewModel)
            }
            .sheet(isPresented: $viewModel.isShowingChat) {
                ChatView(viewModel: viewModel)
                    .onAppear {
                        chatManager.hasUnreadMessage = false
                    }
            }
            .sheet(isPresented: $viewModel.isShowQuestionList, content: {
                QuestionList(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.bottom)
            })
        }
        .background(
            Image.videoCallBackgroundPattern
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear(perform: {
            Task {
                await viewModel.getUsers()
                streamManager.connect(meetingId: viewModel.meeting.id.orEmpty())
                viewModel.getRealTime()
                
                
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(named: "btn-stroke-1")
                UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray
                
                AppDelegate.orientationLock = .all
                UIApplication.shared.isIdleTimerDisabled = true
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
            }
        })
        .onChange(of: streamViewModel.hasNewQuestion, perform: { newValue in
            if newValue {
                viewModel.getQuestion(meetingId: viewModel.meeting.id.orEmpty())
            }
        })
        .navigationBarTitle(Text(""))
        .navigationBarHidden(true)
        .onDisappear {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
            AppDelegate.orientationLock = .portrait
            UIApplication.shared.isIdleTimerDisabled = false
            UIPageControl.appearance().pageIndicatorTintColor = UIColor(named: "btn-color-1")
        }
    }
}

struct TwilioGroupVideoCallView_Previews: PreviewProvider {
    static var previews: some View {
        TwilioGroupVideoCallView(
            viewModel: TwilioLiveStreamViewModel(
                backToRoot: {},
                backToHome: {},
                meeting: UserMeetingData(
                    id: "",
                    title: "",
                    meetingDescription: "",
                    price: "",
                    startAt: nil,
                    endAt: nil,
                    isPrivate: false,
                    isLiveStreaming: false,
                    slots: 0,
                    participants: 0,
                    userID: "",
                    startedAt: Date(),
                    endedAt: nil,
                    createdAt: nil,
                    updatedAt: nil,
                    deletedAt: nil,
                    bookings: nil,
                    user: nil,
                    participantDetails: nil,
                    meetingBundleId: nil,
                    meetingRequestId: nil,
                    status: nil,
                    meetingRequest: nil,
                    expiredAt: nil,
                    background: nil,
                    meetingCollaborations: nil,
                    meetingUrls: nil,
                    meetingUploads: nil
                )
            ),
            meetingId: .constant(""), speaker: SpeakerVideoViewModel()
        )
    }
}

extension Alert {
    init(error: Error?, action: (() -> Void)? = nil) {
        self.init(
            title: Text(LocaleText.errorText),
            message: Text(((error as? UnauthResponse)?.message) ?? (error?.localizedDescription.debugDescription).orEmpty()),
            dismissButton: .default(Text("OK")) {
                action?()
            }
        )
    }
}
