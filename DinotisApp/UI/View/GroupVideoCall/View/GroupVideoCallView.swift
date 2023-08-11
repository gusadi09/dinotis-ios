//
//  GroupVideoCallView.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/23.
//

import DinotisDesignSystem
import DinotisData
import DyteiOSCore
import SwiftUI
import SwiftUINavigation

enum SizeClass {
    case compactRegular
    case compactCompact
    case regularCompact
    case regularRegular
}

struct GroupVideoCallView: View {
    
    @ObservedObject var viewModel: GroupVideoCallViewModel
    
    var body: some View {
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
            
            GeometryReader { geo in
                Image.videoCallBackgroundPattern
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
            }
            .ignoresSafeArea()
            
            if viewModel.isInit {
                if viewModel.meeting.localUser.waitListStatus == .waiting || viewModel.meeting.localUser.waitListStatus == .rejected {
                    WaitingRoomView(viewModel: viewModel)
                } else if viewModel.isJoined {
                    if viewModel.isReceivedStageInvite {
                        GroupVideoCallPreview(viewModel: viewModel)
                    } else {
                        MainGroupVideoCallView(viewModel: viewModel)
                    }
                } else {
                    GroupVideoCallPreview(viewModel: viewModel)
                }
                
            }
            
            DinotisLoadingView(.fullscreen, hide: !viewModel.isConnecting)
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.onAppear()
            AppDelegate.orientationLock = .all
            
            UIApplication.shared.isIdleTimerDisabled = true
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        }
        .onDisappear {
            viewModel.onDisappear()
            AppDelegate.orientationLock = .portrait
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        }
        .sheet(isPresented: $viewModel.isShowAboutCallBottomSheet) {
            AboutCallBottomSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.isShowingQnA) {
            QnAListBottomSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.isShowQuestionBox) {
            if #available(iOS 16.0, *) {
                QuestionBoxBottomSheet(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            } else {
                QuestionBoxBottomSheet(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $viewModel.showingMoreMenu, content: {
            if #available(iOS 16.0, *) {
                MoreMenuSheet(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            } else {
                MoreMenuSheet(viewModel: viewModel)
            }
        })
        .sheet(isPresented: $viewModel.isShowSessionInfo) {
            if #available(iOS 16.0, *) {
                SessionInfoBottomSheet(viewModel: viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
            } else {
                SessionInfoBottomSheet(viewModel: viewModel)
            }
        }
        .alert(isPresented: $viewModel.isShowNearEndAlert) {
            Alert(
                title: Text(LocalizableText.videoCallFiveMinutesLeftAlertTitle),
                message: Text(LocalizableText.videoCallFiveMinutesLeftAlertDesc),
                dismissButton: .default(Text(LocalizableText.understoodText))
            )
        }
        .alert(isPresented: $viewModel.isKicked) {
            Alert(
                title: Text(LocalizableText.attentionText),
                message: Text(LocalizableText.videoCallRemovedFromRoomMessage),
                dismissButton: .default(
                    Text(LocalizableText.understoodText),
                    action: {
                        self.viewModel.isConnecting = false
                        self.viewModel.routeToAfterCall()
                    }
                )
            )
        }
        .alert(
            LocalizableText.attentionText,
            isPresented: $viewModel.isError,
            presenting: viewModel.error
        ) { action in
            switch action {
            case .api(_):
                Button(LocalizableText.videoCallLeaveRoom, role: .destructive) {
                    viewModel.leaveMeeting()
                }
            case .connection(_):
                Button(LocalizableText.videoCallLeaveRoom, role: .destructive) {
                    viewModel.leaveMeeting()
                }
                Button(LocalizableText.videoCallRejoin, role: .cancel) {
                    viewModel.joinMeeting()
                }

            default:
                Button {
                    print(action.errorDescription)
                } label: {
                    Text(LocalizableText.okText)
                }

            }
        } message: { message in
            Text(message.errorDescription)
        }
    }
}

fileprivate extension GroupVideoCallView {
    
    struct MainGroupVideoCallView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Environment(\.verticalSizeClass) var verticalSizeClass
        @Environment(\.horizontalSizeClass) var horizontalSizeClass
        var isPortrait: Bool {
            horizontalSizeClass == .compact && verticalSizeClass == .regular
        }
        
        var body: some View {
            VStack {
                Spacer()
                    .frame(height: 50)
                    .isHidden(!viewModel.isShowingToolbar || !isPortrait, remove: !viewModel.isShowingToolbar || !isPortrait)
                
                TabView(selection: $viewModel.index) {
                    if viewModel.meeting.participants.pinned != nil || !viewModel.screenShareUser.isEmpty {
                        VStack {
                            if viewModel.screenShareUser.isEmpty {
                                
                                RemoteUserPinnedPrimaryVideoContainerView(viewModel: viewModel)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                
                            } else {
                                RemoteScreenShareVideoContainerView(viewModel: viewModel, participant: $viewModel.screenShareId)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                            }
                            
                            Spacer()
                                .frame(height: 116)
                                .isHidden(!viewModel.isShowingToolbar || !isPortrait, remove: !viewModel.isShowingToolbar || !isPortrait)
                        }
                        .tag(0)
                    }
                    
                    VStack {
                        if viewModel.isJoined {
                            if viewModel.meeting.stage.onStage.isEmpty {
                                VStack(spacing: 15) {
                                    Spacer()
                                    
                                    LottieView(name: "waiting-talent", loopMode: .loop)
                                        .scaledToFit()
                                        .frame(height: 225)
                                    
                                    Text(LocalizableText.videoCallWaitingCreatorTitle)
                                        .font(.robotoBold(size: 22))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Text(LocalizableText.videoCallWaitingCreatorSubtitle)
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Spacer()
                                }
                            } else {
                                ScrollView {
                                    LazyVStack {
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 176))]) {
                                            ForEach($viewModel.participants, id: \.id) { item in
                                                RemoteUserJoinedTileVideoContainerView(viewModel: viewModel, participant: item)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onTapGesture {
                    withAnimation {
                        viewModel.isShowingToolbar.toggle()
                    }
                }
            }
            .onChange(of: viewModel.activePage, perform: { newValue in
                viewModel.setPage(to: newValue)
            })
            .overlay {
                VStack {
                    HStack {
                        if !viewModel.screenShareUser.isEmpty && viewModel.screenShareUser.count > 1 {
                            Menu {
                                ForEach(viewModel.screenShareUser, id: \.id) { item in
                                    Button {
                                        viewModel.screenShareId = nil
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                                            self.viewModel.screenShareId = item
                                        }
                                    } label: {
                                        HStack {
                                            if viewModel.screenShareId?.id ?? "" == item.id {
                                                Image(systemName: "checkmark")
                                            }
                                            
                                            Text(item.name + " (\(LocalizableText.videoCallScreenShareText))")
                                        }
                                    }
                                    .tag(item)
                                    .buttonStyle(.plain)
                                }
                                
                            } label: {
                                HStack(spacing: 10) {
                                    Text("\(viewModel.screenShareId?.name ?? "") (\(LocalizableText.videoCallScreenShareText))")
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "chevron.down")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 5)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.DinotisDefault.black1)
                                )
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.DinotisDefault.primary, lineWidth: 1))
                            }
                            
                            Spacer()
                        }
                        
                        HStack(spacing: 4) {
                            Image.videoCallClockWhiteIcon
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(viewModel.isNearbyEnd ? .white : .primaryRed)
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
                        
                        if viewModel.isJoined {
                            
                            if viewModel.meeting.localUser.stageStatus == .onStage {
                                Button {
                                    withAnimation(.spring()) {
                                        viewModel.switchCamera()
                                    }
                                } label: {
                                    Image.videoCallFlipCameraWhiteIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 32)
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Image.videoCallLiveWhiteIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 24)
                                    
                                    Text(LocalizableText.liveText)
                                        .font(.robotoBold(size: 12))
                                        .foregroundColor(.white)
                                }
                                .padding(.leading, 6)
                                .padding(.trailing, 12)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .foregroundColor(.DinotisDefault.red)
                                )
                            }
                            
                        } else {
                            HStack(spacing: 8) {
                                Image.videoCallLiveWhiteIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 24)
                                
                                Text(LocalizableText.liveText)
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.white)
                            }
                            .padding(.leading, 6)
                            .padding(.trailing, 12)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .foregroundColor(.DinotisDefault.red)
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .isHidden(!viewModel.isShowingToolbar, remove: !viewModel.isShowingToolbar)
                    
                    Spacer()
                    
                    VStack {
                        if viewModel.isJoined {
                            if viewModel.index == 1 {
                                HStack(spacing: 15) {
                                    
                                    Button {
                                        viewModel.activePage -= 1
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 10, weight: .bold, design: .rounded))
                                            .foregroundColor(.white.opacity(!viewModel.meeting.participants.canGoPreviousPage ? 0.5 : 1))
                                            .padding(8)
                                            .background(
                                                Circle()
                                                    .foregroundColor(!viewModel.meeting.participants.canGoPreviousPage ? .DinotisDefault.black3 : .DinotisDefault.primary)
                                            )
                                    }
                                    .disabled(!viewModel.meeting.participants.canGoPreviousPage)
                                    
                                    Text("\(viewModel.activePage == 0 ? "Auto" : "\(viewModel.activePage)")")
                                        .font(.robotoRegular(size: 14))
                                        .foregroundColor(.white)
                                    
                                    Button {
                                        viewModel.activePage += 1
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 10, weight: .bold, design: .rounded))
                                            .foregroundColor(.white.opacity(!viewModel.meeting.participants.canGoNextPage ? 0.5 : 1))
                                            .padding(8)
                                            .background(
                                                Circle()
                                                    .foregroundColor(!viewModel.meeting.participants.canGoNextPage ? .DinotisDefault.black3 : .DinotisDefault.primary)
                                            )
                                    }
                                    .disabled(!viewModel.meeting.participants.canGoNextPage)
                                }
                            }
                        }
                        
                        HStack(spacing: 5) {
                            if viewModel.meeting.participants.pinned != nil || !viewModel.screenShareUser.isEmpty {
                                ForEach(0...1, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 30)
                                        .foregroundColor(viewModel.index == index ? .DinotisDefault.primary : .gray)
                                        .frame(width: 16, height: 8)
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 30)
                                    .foregroundColor(.DinotisDefault.primary)
                                    .frame(width: 16, height: 8)
                            }
                        }
                    }
                    .padding(.bottom, viewModel.isShowingToolbar ? 0 : 24)
                    
                    BottomToolBar(viewModel: viewModel)
                        .isHidden(!viewModel.isShowingToolbar, remove: !viewModel.isShowingToolbar)
                }
            }
            .alert(isPresented: $viewModel.showConnectionErrorAlert, content: {
                      Alert(
                          title: Text("Error"),
                          message: Text(viewModel.connectionError ?? "An unknown error occurred."),
                          dismissButton: .default(Text("Rejoin")) {
                              viewModel.showConnectionErrorAlert = false
                              viewModel.joinMeeting()
                          }
                      )
                  })
        }
    }
    
    struct GroupVideoCallPreview: View {
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Environment(\.verticalSizeClass) var verticalSizeClass
        @Environment(\.horizontalSizeClass) var horizontalSizeClass
        var classType: SizeClass {
            if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                return .compactRegular
            } else if horizontalSizeClass == .compact && verticalSizeClass == .compact {
                return .compactCompact
            } else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                return .regularCompact
            } else {
                return .regularRegular
            }
        }
        
        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, d MMMM, h:mm a"
            return formatter
        }()
        
        var body: some View {
            switch classType {
            case .compactRegular:
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        let dateString = Self.dateFormatter.string(from: viewModel.userMeeting.startedAt.orCurrentDate())
                        
                        Text(LocalizableText.videoCallSessionTitle(
                            creatorName: (viewModel.userMeeting.user?.name).orEmpty()
                        ))
                        .font(.robotoBold(size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        
                        Text("\(LocalizableText.videoCallScheduledText): \(dateString)")
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(Color(red: 0.63, green: 0.64, blue: 0.66))
                            .multilineTextAlignment(.leading)
                    }
                    
                    ZStack(alignment: .bottomTrailing) {
                        LocalUserVideoContainerView(viewModel: viewModel)
                        
                        HStack(spacing: 4) {
                            Button {
                                viewModel.toggleCamera()
                            } label: {
                                (viewModel.isCameraOn ? Image.videoCallVideoOnStrokeIcon : Image.videoCallVideoOffStrokeIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .foregroundColor(Color(red: 0.21, green: 0.22, blue: 0.22))
                                    )
                                    .frame(width: 48, height: 48)
                            }
                            
                            Button {
                                viewModel.toggleMicrophone()
                            } label: {
                                (viewModel.isAudioOn ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .foregroundColor(Color(red: 0.21, green: 0.22, blue: 0.22))
                                    )
                                    .frame(width: 48, height: 48)
                            }
                        }
                        .padding(8)
                    }
                    .frame(height: 216)
                    
                    DinotisPrimaryButton(
                        text: LocalizableText.labelJoinNow,
                        type: .adaptiveScreen,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary) {
                            if viewModel.isReceivedStageInvite {
                                viewModel.meeting.stage.join()
                            } else {
                                viewModel.joinMeeting()
                            }
                        }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color(red: 0.15, green: 0.16, blue: 0.17))
                )
                .frame(maxWidth: 400)
                .padding()
            default:
                HStack(spacing: 24) {
                    GeometryReader { geo in
                        VStack {
                            Spacer()
                            ZStack(alignment: .bottomTrailing) {
                                LocalUserVideoContainerView(viewModel: viewModel)
                                
                                HStack(spacing: 4) {
                                    Button {
                                        viewModel.toggleCamera()
                                    } label: {
                                        (viewModel.isCameraOn ? Image.videoCallVideoOnStrokeIcon : Image.videoCallVideoOffStrokeIcon)
                                            .resizable()
                                            .scaledToFit()
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .foregroundColor(Color(red: 0.21, green: 0.22, blue: 0.22))
                                            )
                                            .frame(width: 48, height: 48)
                                    }
                                    
                                    Button {
                                        viewModel.toggleMicrophone()
                                    } label: {
                                        (viewModel.isAudioOn ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
                                            .resizable()
                                            .scaledToFit()
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .foregroundColor(Color(red: 0.21, green: 0.22, blue: 0.22))
                                            )
                                            .frame(width: 48, height: 48)
                                    }
                                }
                                .padding(8)
                            }
                            .frame(width: geo.size.width, height: geo.size.width*9/16)
                            Spacer()
                        }
                    }
                    
                    VStack(spacing: 24) {
                        VStack(spacing: 4) {
                            let dateString = Self.dateFormatter.string(from: viewModel.userMeeting.startedAt.orCurrentDate())
                            
                            Text(LocalizableText.videoCallSessionTitle(
                                creatorName: (viewModel.userMeeting.user?.name).orEmpty()
                            ))
                            .font(.robotoBold(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            
                            Text("\(LocalizableText.videoCallScheduledText): \(dateString)")
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(Color(red: 0.63, green: 0.64, blue: 0.66))
                                .multilineTextAlignment(.center)
                        }
                        
                        DinotisPrimaryButton(
                            text: LocalizableText.labelJoinNow,
                            type: .adaptiveScreen,
                            textColor: .white,
                            bgColor: .DinotisDefault.primary) {
                                if viewModel.isReceivedStageInvite {
                                    viewModel.meeting.stage.join()
                                } else {
                                    viewModel.joinMeeting()
                                }
                            }
                    }
                    .frame(maxWidth: 320)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color(red: 0.15, green: 0.16, blue: 0.17))
                )
                .frame(maxWidth: 1040, maxHeight: 416)
                .padding()
            }
        }
    }
    
    struct WaitingRoomView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Environment(\.verticalSizeClass) var verticalSizeClass
        @Environment(\.horizontalSizeClass) var horizontalSizeClass
        var isPortrait: Bool {
            horizontalSizeClass == .compact && verticalSizeClass == .regular
        }
        
        var body: some View {
            AdaptiveStack(
                isHorizontalStack: !isPortrait,
                spacing: 22) {
                    VStack(spacing: 12) {
                        Text(LocalizableText.videoCallWaitingRoomTitle)
                            .font(.robotoBold(size: 20))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(LocalizableText.videoCallWaitingRoomDesc)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        CircleLoadingView()
                    }
                    
                    VStack {
                        Spacer()
                        
                        Image.logoWhiteText
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 130)
                        
                        Spacer()
                        
                        Text(LocalizableText.videoCallSessionTitle(
                            creatorName: (viewModel.userMeeting.user?.name).orEmpty()
                        ))
                        .font(.robotoBold(size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        
                        Text("\(LocalizableText.videoCallScheduledText): \(DateUtils.dateFormatter(viewModel.userMeeting.startedAt.orCurrentDate(), forFormat: .EEEEdMMMMhmma))")
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(Color(red: 0.63, green: 0.64, blue: 0.66))
                            .multilineTextAlignment(.center)
                    }
                    .padding(46)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.15, green: 0.16, blue: 0.17))
                    .cornerRadius(20)
                }
                .padding()
        }
    }
    
    struct MoreMenuSheet: View {
        @ObservedObject var viewModel: GroupVideoCallViewModel
        
        var body: some View {
            VStack {
                HStack {
                    Text(LocalizableText.videoCallMoreMenu)
                        .font(.robotoBold(size: 15))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        viewModel.showingMoreMenu = false
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                }
                .padding(15)
                .background(
                    Rectangle()
                        .foregroundColor(.black)
                )
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if viewModel.meeting.localUser.stageStatus == .onStage {
                            Button {
                                viewModel.showingMoreMenu = false
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                    if self.viewModel.meeting.localUser.presetName == PresetConstant.viewer.value {
                                        self.viewModel.isShowQuestionBox.toggle()
                                    } else {
                                        self.viewModel.isShowingQnA.toggle()
                                    }
                                }
                            } label: {
                                HStack(alignment: .center, spacing: 11) {
                                    ZStack(alignment: .topTrailing, content: {
                                        Image.videoCallQuestionIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 23)
                                        
                                        if viewModel.hasNewQuestion {
                                            Circle()
                                                .foregroundColor(.red)
                                                .scaledToFit()
                                                .frame(width: 10)
                                        }
                                    })
                                    
                                    
                                    Text(LocalizableText.videoCallQna)
                                        .foregroundColor(.white)
                                        .font(.robotoRegular(size: 16))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .frame(width: 8)
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                }
                                .padding(15)
                                .contentShape(Rectangle())
                            }
                        }
                        
                        Button {
                            viewModel.showingMoreMenu = false
                            viewModel.tabSelection = 2
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                self.viewModel.isShowAboutCallBottomSheet = true
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 11) {
                                Image.videoCallPollingIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 23)
                                
                                Text(LocalizableText.videoCallPolls)
                                    .foregroundColor(.white)
                                    .font(.robotoRegular(size: 16))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: 8)
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                            }
                            .padding(15)
                            .contentShape(Rectangle())
                        }
                        .isHidden(true, remove: true)
                        
                        Button {
                            viewModel.showingMoreMenu = false
                            viewModel.tabSelection = 1
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                self.viewModel.isShowAboutCallBottomSheet = true
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 11) {
                                ZStack(alignment: .topTrailing, content: {
                                    Image.videoCallNewParticipantIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 23)
                                    
                                    if viewModel.hasNewParticipantRequest {
                                        Circle()
                                            .foregroundColor(.red)
                                            .scaledToFit()
                                            .frame(width: 10)
                                    }
                                })
                                
                                Text(LocalizableText.participant)
                                    .foregroundColor(.white)
                                    .font(.robotoRegular(size: 16))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: 8)
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                            }
                            .padding(15)
                            .contentShape(Rectangle())
                        }
                        
                        if viewModel.meeting.localUser.canDoParticipantHostControls() {
                            Button {
                                
                            } label: {
                                HStack(alignment: .center, spacing: 11) {
                                    Image.videoCallRecordVideoIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 23)
                                    
                                    Text(LocalizableText.videoCallRecord)
                                        .foregroundColor(.white)
                                        .font(.robotoRegular(size: 16))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .frame(width: 8)
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                }
                                .padding(15)
                                .contentShape(Rectangle())
                            }
                            .isHidden(true, remove: true)
                        }
                        
                        Button {
                            viewModel.showingMoreMenu = false
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                self.viewModel.isShowSessionInfo = true
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 11) {
                                Image.videoCallInformationIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 23)
                                
                                Text(LocalizableText.videoCallInformation)
                                    .foregroundColor(.white)
                                    .font(.robotoRegular(size: 16))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: 8)
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                            }
                            .padding(15)
                            .contentShape(Rectangle())
                        }
                    }
                }
                .background(Color(red: 0.15, green: 0.16, blue: 0.17))
            }
            .background(Color(red: 0.15, green: 0.16, blue: 0.17))
        }
    }
    
    struct BottomToolBar: View {
        @ObservedObject var viewModel: GroupVideoCallViewModel
        
        var body: some View {
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring()) {
                        if viewModel.meeting.localUser.stageStatus == .onStage {
                            viewModel.toggleMicrophone()
                        } else {
                            if viewModel.isRaised {
                                viewModel.meeting.stage.cancelRequestAccess()
                            } else {
                                viewModel.meeting.stage.requestAccess()
                            }
                            
                            viewModel.isRaised = !viewModel.isRaised
                        }
                    }
                } label: {
                    if viewModel.meeting.localUser.stageStatus == .onStage {
                        (viewModel.isAudioOn ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 32)
                    } else {
                        if viewModel.isRaised {
                            Image.videoCallRaiseHandInactive
                                .resizable()
                                .scaledToFit()
                                .frame(height: 32)
                        } else {
                            Image.videoCallRaiseHandActive
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                        }
                    }
                }
                .disabled(false) // Add logic when audio is locked
                
                Button {
                    withAnimation(.spring()) {
                        if viewModel.meeting.localUser.stageStatus == .onStage {
                            viewModel.toggleCamera()
                        } else {
                            viewModel.tabSelection = 0
                            viewModel.isShowAboutCallBottomSheet.toggle()
                        }
                    }
                } label: {
                    if viewModel.meeting.localUser.stageStatus == .onStage {
                        (viewModel.isCameraOn ? Image.videoCallVideoOnStrokeIcon : Image.videoCallVideoOffStrokeIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 32)
                    } else {
                        Image.videoCallChatIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                            .foregroundColor(.white)
                            .overlay(alignment: .trailing) {
                                if viewModel.hasNewMessage {
                                    Circle()
                                        .foregroundColor(.red)
                                        .frame(width: 10, height: 10)
                                        .padding(.trailing, 10)
                                        .padding(.bottom, 12)
                                }
                            }
                    }
                }
                
                Button {
                    if viewModel.meeting.localUser.stageStatus == .onStage {
                        viewModel.tabSelection = 0
                        viewModel.isShowAboutCallBottomSheet.toggle()
                    } else {
                        viewModel.isShowQuestionBox.toggle()
                    }
                } label: {
                    if viewModel.meeting.localUser.stageStatus == .onStage {
                        Image.videoCallChatIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                            .foregroundColor(.white)
                            .overlay(alignment: .trailing) {
                                if viewModel.hasNewMessage {
                                    Circle()
                                        .foregroundColor(.red)
                                        .frame(width: 10, height: 10)
                                        .padding(.trailing, 10)
                                        .padding(.bottom, 12)
                                }
                            }
                    } else {
                        Image.videoCallQuestionIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                    }
                }
                
                Button {
                    withAnimation(.spring()) {
                        viewModel.showingMoreMenu.toggle()
                    }
                } label: {
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            Image.videoCallMoreMenuNewIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 45)
                        }
                        
                        if (viewModel.hasNewQuestion || viewModel.hasNewParticipantRequest) && viewModel.meeting.localUser.canDoParticipantHostControls() {
                            Circle()
                                .foregroundColor(.red)
                                .scaledToFit()
                                .frame(width: 10)
                        }
                    }
                }
                
                Button {
                    withAnimation(.spring()) {
                        viewModel.leaveMeeting()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .foregroundColor(.red)
                        
                        Image(systemName: "phone.down.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 24)
                            .padding()
                    }
                    .frame(width: 60, height: 60)
                }
                .disabled(!viewModel.isJoined)
                
            }
            .padding()
            .padding(.horizontal)
            .background(Color.DinotisDefault.black1)
            .cornerRadius(24)
            .padding(.horizontal, 20)
            .padding(.bottom)
        }
    }
    
    struct LocalUserVideoContainerView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                if viewModel.localUser != nil {
                    if viewModel.isCameraOn {
                        if let video = viewModel.localUser?.getVideoView() {
                            UIVideoView(videoView: video, width: .infinity, height: .infinity)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .rotationEffect(.degrees(0))
                                .rotation3DEffect(.degrees(viewModel.position == .rear ? 180 : 0), axis: (0, 1, 0))
                        }
                        
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay(
                                ImageLoader(url: (viewModel.localUser?.picture).orEmpty(), width: .infinity, height: .infinity)
                                    .frame(width: 136, height: 136)
                                    .clipShape(Circle())
                            )
                    }
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                if viewModel.localUser != nil {
                    HStack(spacing: 0) {
                        (
                            (viewModel.localUser?.fetchAudioEnabled() ?? false) ?
                            Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                        
                        Text(" \(viewModel.localUser?.name ?? "") \(viewModel.userType(preset: (viewModel.localUser?.presetName).orEmpty()))")
                            .font(.robotoMedium(size: 10))
                            .foregroundColor(.white)
                    }
                    .padding(5)
                    .background(
                        Capsule()
                            .foregroundColor(.gray.opacity(0.5))
                    )
                    .padding(10)
                    .isHidden(viewModel.isPreview)
                }
            }
        }
    }
    
    struct RemoteUserJoinedTileVideoContainerView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Binding var participant: DyteJoinedMeetingParticipant
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                if viewModel.index == 0 && (viewModel.meeting.participants.pinned?.id).orEmpty() == participant.id {
                    if viewModel.meeting.participants.pinned == nil && viewModel.screenShareUser.isEmpty {
                        if participant.fetchVideoEnabled() {
                            if let video = participant.getVideoView() {
                                UIVideoView(videoView: video, width: 176, height: 246)
                                    .frame(width: 176, height: 246)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                                .frame(width: 176, height: 246)
                                .overlay(
                                    ImageLoader(url: participant.picture.orEmpty(), width: 136, height: 136)
                                        .frame(width: 136, height: 136)
                                        .clipShape(Circle())
                                )
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                            .frame(width: 176, height: 246)
                    }
                    
                } else {
                    if participant.fetchVideoEnabled() {
                        if let video = participant.getVideoView() {
                            UIVideoView(videoView: video, width: 176, height: 246)
                                .frame(width: 176, height: 246)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                            .frame(width: 176, height: 246)
                            .overlay(
                                ImageLoader(url: participant.picture.orEmpty(), width: 136, height: 136)
                                    .frame(width: 136, height: 136)
                                    .clipShape(Circle())
                            )
                    }
                }
                
                HStack(spacing: 0) {
                    (
                        participant.fetchAudioEnabled() ?
                        Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12)
                    
                    if participant.isPinned {
                        Text(" \(participant.name) \(viewModel.userType(preset: participant.presetName)) \(Image(systemName: "pin"))")
                            .font(.robotoMedium(size: 10))
                            .foregroundColor(.white)
                    } else {
                        Text(" \(participant.name) \(viewModel.userType(preset: participant.presetName))")
                            .font(.robotoMedium(size: 10))
                            .foregroundColor(.white)
                    }
                }
                .padding(5)
                .background(
                    Capsule()
                        .foregroundColor(.gray.opacity(0.5))
                )
                .padding(10)
            }
        }
    }
    
    struct RemoteUserPinnedPrimaryVideoContainerView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                if viewModel.index == 1 && (viewModel.pinned?.id == viewModel.meeting.participants.pinned?.id) {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                } else {
                    if viewModel.meeting.participants.pinned?.fetchVideoEnabled() ?? false {
                        if let video = viewModel.meeting.participants.pinned?.getVideoView() {
                            UIVideoView(videoView: video, width: .infinity, height: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                                .overlay(
                                    ImageLoader(url: (viewModel.meeting.participants.pinned?.picture).orEmpty(), width: 136, height: 136)
                                        .frame(width: 136, height: 136)
                                        .clipShape(Circle())
                                )
                        }
                        
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                            .overlay(
                                ImageLoader(url: (viewModel.meeting.participants.pinned?.picture).orEmpty(), width: 136, height: 136)
                                    .frame(width: 136, height: 136)
                                    .clipShape(Circle())
                            )
                    }
                }
                
                HStack(spacing: 0) {
                    (
                        (viewModel.meeting.participants.pinned?.fetchAudioEnabled() ?? false) ?
                        Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12)
                    
                    if viewModel.meeting.participants.pinned?.isPinned ?? false {
                        Text(" \((viewModel.meeting.participants.pinned?.name).orEmpty()) \(viewModel.userType(preset: (viewModel.meeting.participants.pinned?.presetName).orEmpty())) \(Image(systemName: "pin"))")
                            .font(.robotoMedium(size: 10))
                            .foregroundColor(.white)
                    } else {
                        Text(" \((viewModel.meeting.participants.pinned?.name).orEmpty()) \(viewModel.userType(preset: (viewModel.meeting.participants.pinned?.presetName).orEmpty()))")
                            .font(.robotoMedium(size: 10))
                            .foregroundColor(.white)
                    }
                }
                .padding(5)
                .background(
                    Capsule()
                        .foregroundColor(.gray.opacity(0.5))
                )
                .padding(10)
            }
        }
    }
    
    struct RemoteScreenShareVideoContainerView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Binding var participant: DyteScreenShareMeetingParticipant?
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                if viewModel.index == 0 && viewModel.localUser?.id == participant?.id {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.DinotisDefault.green)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    if let video = participant?.getScreenShareVideoView() {
                        UIVideoView(videoView: video, width: .infinity, height: .infinity)
                            .background(
                                Color.black
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                
                HStack(spacing: 0) {
                    (
                        (participant?.fetchAudioEnabled() ?? false) ?
                        Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12)
                    
                    Text(" \(participant?.name ?? "") (\(LocalizableText.videoCallScreenShareText)")
                        .font(.robotoMedium(size: 10))
                        .foregroundColor(.white)
                }
                .padding(5)
                .background(
                    Capsule()
                        .foregroundColor(.gray.opacity(0.5))
                )
                .padding(10)
            }
        }
    }
    
    struct AboutCallBottomSheet: View {
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Environment(\.presentationMode) var presentationMode
        @Namespace var namespace
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text(LocalizableText.aboutCallTitle)
                        .font(.robotoBold(size: 16))
                    
                    Spacer()
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .foregroundColor(.white)
                .padding()
                
                HStack(spacing: 16) {
                    ForEach(viewModel.bottomSheetTabItems, id: \.id) { item in
                        Button {
                            withAnimation {
                                viewModel.tabSelection = item.id
                            }
                        } label: {
                            VStack(spacing: 16) {
                                Text(item.title)
                                    .font(viewModel.tabSelection == item.id ? .robotoBold(size: 16) : .robotoRegular(size: 16))
                                    .foregroundColor(viewModel.tabSelection == item.id ? .white : Color(red: 0.63, green: 0.64, blue: 0.66))
                                if viewModel.tabSelection == item.id {
                                    RoundedRectangle(cornerRadius: 8)
                                        .frame(width: CGFloat(item.title.count * 8), height: 2)
                                        .foregroundColor(.DinotisDefault.primary)
                                        .matchedGeometryEffect(id: "bottom", in: namespace)
                                } else {
                                    Rectangle()
                                        .frame(width: CGFloat(item.title.count * 8), height: 2)
                                        .foregroundColor(.clear)
                                }
                                
                                
                            }
                            .animation(.spring(), value: viewModel.tabSelection)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                Group {
                    switch viewModel.tabSelection {
                    case 0:
                        ChatView(viewModel: viewModel)
                    case 1:
                        ParticipantTabView(viewModel: viewModel)
//                    case 2:
//                        PollingView()
                    default:
                        EmptyView()
                    }
                }
                .animation(.easeInOut, value: viewModel.tabSelection)
            }
            
            
        }
    }
    
    struct SessionInfoBottomSheet: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            VStack {
                HStack {
                    Text(LocalizableText.videoCallInformation)
                        .font(.robotoBold(size: 16))
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .foregroundColor(.white)
                .padding()
                .background(Color(red: 0.1, green: 0.11, blue: 0.12))
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        Text(viewModel.userMeeting.title.orEmpty())
                            .font(.robotoBold(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        VStack(alignment: .leading, spacing: 18) {
                            HStack(alignment: .top, spacing: 16) {
                                Text(LocalizableText.speakerTitle)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(Color(red: 0.79, green: 0.8, blue: 0.81))
                                    .frame(width: 80, alignment: .leading)
                                
                                Text(viewModel.hostNames)
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer(minLength: 1)
                            }
                            
                            HStack(alignment: .top, spacing: 16) {
                                Text(LocalizableText.videoCallScheduledText)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(Color(red: 0.79, green: 0.8, blue: 0.81))
                                    .frame(width: 80, alignment: .leading)
                                
                                Text(viewModel.userMeeting.startAt.orCurrentDate(), style: .date)
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer(minLength: 1)
                            }
                            
                            HStack(alignment: .top, spacing: 16) {
                                Text(LocalizableText.timeText)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(Color(red: 0.79, green: 0.8, blue: 0.81))
                                    .frame(width: 80, alignment: .leading)
                                
                                (
                                    Text(viewModel.userMeeting.startAt.orCurrentDate(), style: .time)
                                    +
                                    Text(" - ")
                                    +
                                    Text(viewModel.userMeeting.endAt.orCurrentDate(), style: .time)
                                )
                                .font(.robotoBold(size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                
                                Spacer(minLength: 1)
                            }
                            
                            HStack(alignment: .top, spacing: 16) {
                                Text(LocalizableText.typeText)
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(Color(red: 0.79, green: 0.8, blue: 0.81))
                                    .frame(width: 80, alignment: .leading)
                                
                                Text(LocalizableText.groupCallText)
                                    .font(.robotoBold(size: 12))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer(minLength: 1)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color(red: 0.15, green: 0.16, blue: 0.17))
        }
    }
    
    struct QnAListBottomSheet: View {
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Environment(\.presentationMode) var presentationMode
        @Namespace var namespace
        
        var body: some View {
            VStack(alignment: .leading) {
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(LocalizableText.videoCallListQuestionTitle)
                            .font(.robotoBold(size: 16))
                        
                        Spacer()
                        
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    HStack(spacing: 16) {
                        ForEach(viewModel.qnaTabItems, id: \.id) { item in
                            Button {
                                withAnimation {
                                    viewModel.qnaTabSelection = item.id
                                }
                            } label: {
                                VStack(spacing: 16) {
                                    Text(item.title)
                                        .font(viewModel.qnaTabSelection == item.id ? .robotoBold(size: 16) : .robotoMedium(size: 16))
                                        .foregroundColor(viewModel.qnaTabSelection == item.id ? .white : Color(red: 0.63, green: 0.64, blue: 0.66))
                                    
                                    if viewModel.qnaTabSelection == item.id {
                                        RoundedRectangle(cornerRadius: 8)
                                            .frame(width: 24, height: 2)
                                            .foregroundColor(.DinotisDefault.primary)
                                            .matchedGeometryEffect(id: "qna-bottom", in: namespace)
                                    } else {
                                        Rectangle()
                                            .frame(width: 24, height: 2)
                                            .foregroundColor(.clear)
                                    }
                                }
                                .animation(.spring(), value: viewModel.qnaTabSelection)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .background(Color(red: 0.1, green: 0.11, blue: 0.12))
                
                TabView(selection: $viewModel.qnaTabSelection) {
                    ScrollViewReader { scroll in
                        Group {
                            if !viewModel.questionData.filter({ item in
                                item.isAnswered == false
                            }).isEmpty {
                                ScrollView {
                                    LazyVStack(spacing: 22) {
                                        
                                        ForEach(viewModel.questionData.filter({ item in
                                            item.isAnswered == false
                                        }), id: \.id) { item in
                                            Button {
                                                viewModel.putQuestion(item: item)
                                            } label: {
                                                QnARowView(data: item, hasAnswered: false, viewModel: viewModel)
                                            }
                                            .id(item.id)
                                        }
                                        
                                    }
                                    .padding(.horizontal)
                                    .padding(.top)
                                }
                                
                            } else {
                                LazyVStack {
                                    Spacer()
                                    
                                    Text(LocalizableText.videoCallQnAEmptyText)
                                        .font(.robotoRegular(size: 12))
                                        .foregroundColor(.DinotisDefault.black3)
                                        .multilineTextAlignment(.center)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .onAppear {
                            viewModel.getQuestion(meetingId: viewModel.userMeeting.id.orEmpty())
                        }
                        .onChange(of: viewModel.questionData.filter({ item in
                            item.isAnswered == false
                        }).count, perform: { _ in
                            withAnimation {
                                scroll.scrollTo((viewModel.questionData.filter({ item in
                                    item.isAnswered == false
                                }).last?.id).orZero())
                            }
                        })
                        .onChange(
                            of: viewModel.hasNewQuestion,
                            perform: { _ in
                                viewModel.getQuestion(meetingId: viewModel.userMeeting.id.orEmpty())
                            }
                        )
                    }
                    .tag(0)
                    
                    Group {
                        if !viewModel.questionData.filter({ item in
                            item.isAnswered == true
                        }).isEmpty {
                            ScrollView {
                                LazyVStack(spacing: 22) {
                                    
                                    ForEach(viewModel.questionData.filter({ item in
                                        item.isAnswered == true
                                    }), id: \.id) { item in
                                        Button {
                                            viewModel.putQuestion(item: item)
                                        } label: {
                                            QnARowView(data: item, hasAnswered: true, viewModel: viewModel)
                                        }
                                    }
                                    
                                }
                                .padding(.horizontal)
                                .padding(.top)
                            }
                        } else {
                            LazyVStack {
                                Spacer()
                                
                                Text(LocalizableText.videoCallQnaAnsweredEmptyText)
                                    .font(.robotoRegular(size: 12))
                                    .foregroundColor(.DinotisDefault.black3)
                                    .multilineTextAlignment(.center)
                                
                                Spacer()
                            }
                        }
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
            }
            .background(Color(red: 0.15, green: 0.16, blue: 0.17))
            .onDisappear {
                self.viewModel.hasNewQuestion = false
            }
            
        }
    }
    
    struct QuestionBoxBottomSheet: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            VStack(spacing: 14) {
                HStack {
                    Text(LocalizableText.videoCallBoxQuestionTitle)
                        .font(.robotoBold(size: 16))
                    
                    Spacer()
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                .foregroundColor(.white)
                .padding()
                .background(Color(red: 0.1, green: 0.11, blue: 0.12))
                
                Spacer()
                
                ZStack(alignment: .top) {
                    VStack {
                        MultilineTextField(LocalizableText.videoCallMessagePlaceholder, text: $viewModel.questionText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                        
                        Spacer()
                    }
                    .frame(height: 152)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 0.32, green: 0.34, blue: 0.36), lineWidth: 1)
                        .frame(height: 152)
                }
                .frame(height: 152)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                
                Button {
                    viewModel.postQuestion(meetingId: viewModel.userMeeting.id.orEmpty())
                } label: {
                    HStack(spacing: 13) {
                        Spacer()
                        Text(LocalizableText.videoCallSendQuestionTitle)
                            .font(.robotoBold(size: 16))
                        
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .scaledToFit()
                            .rotationEffect(.degrees(45))
                            .frame(height: 18)
                        
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background((viewModel.questionText.isEmpty || !viewModel.questionText.isStringContainWhitespaceAndText()) ? Color.dinotisGray : Color.DinotisDefault.primary)
                    .cornerRadius(11)
                    .disabled(viewModel.questionText.isEmpty || !viewModel.questionText.isStringContainWhitespaceAndText())
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(red: 0.15, green: 0.16, blue: 0.17))
        }
    }
    
    struct QnARowView: View {
        
        @State var data: QuestionResponse
        @State var hasAnswered: Bool
        @ObservedObject var viewModel: GroupVideoCallViewModel
        
        var body: some View {
            HStack(alignment: .top, spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(hasAnswered ? .DinotisDefault.primary : Color(red: 0.74, green: 0.74, blue: 0.74))
                    
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .font(.system(.headline))
                        .padding(4)
                        .isHidden(!hasAnswered)
                }
                .frame(width: 18, height: 18)
                
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text((data.user?.name).orEmpty())
                            .font(.robotoMedium(size: 12))
                        
                        Spacer()
                        
                        Text((data.createdAt).orCurrentDate(), style: .time)
                            .font(.robotoBold(size: 12))
                    }
                    .foregroundColor(Color(red: 0.63, green: 0.64, blue: 0.66))
                    
                    Text((data.question).orEmpty())
                        .font(.robotoMedium(size: 12))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                .padding(12)
                .background(Color(red: 0.26, green: 0.27, blue: 0.28))
                .cornerRadius(6)
            }
        }
    }
    
    
    struct ParticipantTabView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @State var isAlert: Bool = false
        @State var isAlertPutToSpeaker: Bool = false
        
        var body: some View {
            VStack {
                HStack(spacing: 12) {
                    Image.bottomNavigationSearchWhiteIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    TextField(LocalizableText.generalSearchPlaceholder, text: $viewModel.searchText)
                        .font(.robotoRegular(size: 16))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color(red: 0.18, green: 0.19, blue: 0.2))
                
                List {
                    if viewModel.localUser?.canDoParticipantHostControls() ?? false {
                        if !viewModel.meeting.stage.accessRequests.isEmpty {
                            Section(
                                header: HStack {
                                    Text("\(LocalizableText.videoCallJoinStageRequest) (\(viewModel.meeting.stage.accessRequests.count))")
                                        .font(.robotoBold(size: 16))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button {
                                        viewModel.meeting.stage.grantAccessAll()
                                    } label: {
                                        Text(LocalizableText.acceptAllLabel)
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .frame(width: 103, alignment: .center)
                                            .background(Color.DinotisDefault.primary)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            ) {
                                ForEach(viewModel.meeting.stage.accessRequests, id: \.id) { participant in
                                    HStack(spacing: 16) {
                                        ImageLoader(url: participant.picture.orEmpty(), width: 42, height: 42)
                                            .frame(width: 42, height: 42)
                                            .clipShape(Circle())
                                        
                                        Text(participant.name)
                                            .font(.robotoBold(size: 16))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Button {
                                            viewModel.meeting.stage.grantAccess(id: participant.id)
                                        } label: {
                                            Text(LocalizableText.acceptToJoinLabel)
                                                .font(.robotoBold(size: 12))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 8)
                                                .frame(width: 103, alignment: .center)
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .inset(by: 0.5)
                                                        .stroke(Color.DinotisDefault.black2, lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .listRowSeparator(.hidden)
                                }
                            }
                            .listRowSeparator(.hidden)
                        }
                        
                        if !viewModel.meeting.participants.waitlisted.isEmpty {
                            Section(
                                header: HStack {
                                    Text("\(LocalizableText.titleWaitingRoom) (\(viewModel.meeting.participants.waitlisted.count))")
                                        .font(.robotoBold(size: 16))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button {
                                        viewModel.acceptAllWaitingRequest()
                                        
                                    } label: {
                                        Text(LocalizableText.acceptAllLabel)
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .frame(width: 103, alignment: .center)
                                            .background(Color.DinotisDefault.primary)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            ) {
                                ForEach(viewModel.meeting.participants.waitlisted, id: \.id) { participant in
                                    HStack(spacing: 16) {
                                        ImageLoader(url: participant.picture.orEmpty(), width: 42, height: 42)
                                            .frame(width: 42, height: 42)
                                            .clipShape(Circle())
                                        
                                        Text(participant.name)
                                            .font(.robotoBold(size: 16))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Button {
                                            viewModel.acceptWaitlisted(participant)
                                            
                                        } label: {
                                            Text(LocalizableText.acceptToJoinLabel)
                                                .font(.robotoBold(size: 12))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 8)
                                                .frame(width: 103, alignment: .center)
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .inset(by: 0.5)
                                                        .stroke(Color.DinotisDefault.black2, lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .listRowSeparator(.hidden)
                                }
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    
                    if !viewModel.meeting.stage.onStage.isEmpty {
                        Section(
                            header: HStack {
                                Text("\(LocalizableText.speakerTitle) (\(viewModel.meeting.stage.onStage.count))")
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                        ) {
                            ForEach(viewModel.meeting.stage.onStage, id: \.id) { participant in
                                HStack(spacing: 16) {
                                    ImageLoader(url: participant.picture.orEmpty(), width: 42, height: 42)
                                        .frame(width: 42, height: 42)
                                        .clipShape(Circle())
                                    
                                    if participant.isPinned {
                                        Text("\(participant.name) \(viewModel.userType(preset: participant.presetName)) \(Image(systemName: "pin"))")
                                            .font(.robotoBold(size: 16))
                                            .foregroundColor(.white)
                                    } else {
                                        Text("\(participant.name) \(viewModel.userType(preset: participant.presetName))")
                                            .font(.robotoBold(size: 16))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        (participant.fetchAudioEnabled() ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24)

                                        (participant.fetchVideoEnabled() ? Image.videoCallVideoOnStrokeIcon : Image.videoCallVideoOffStrokeIcon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24)
                                        
                                        if viewModel.localUser?.canDoParticipantHostControls() ?? false {
                                            Menu {
                                                Button {
                                                    
                                                    viewModel.pinParticipant(participant)
                                                    
                                                } label: {
                                                    (participant.isPinned ? Image(systemName: "pin.slash") : Image.videoCallPinIcon)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 24)
                                                    Text(participant.isPinned ? LocalizableText.videoCallUnpinParticipant : LocalizableText.videoCallPinParticipant)
                                                }
                                                if participant.id != (viewModel.localUser?.id).orEmpty() {
                                                    Button {
                                                        viewModel.forceDisableAudio(participant)
                                                    } label: {
                                                        Image.videoCallMicOffStrokeIcon
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 24)
                                                        Text(LocalizableText.videoCallMuteParticipant)
                                                    }
                                                }
                                                if participant.id != (viewModel.localUser?.id).orEmpty() {
                                                    Button {
                                                        viewModel.forceDisableVideo(participant)
                                                    } label: {
                                                        Image.videoCallVideoOffStrokeIcon
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 24)
                                                        Text(LocalizableText.videoCallOffVideo)
                                                    }
                                                }
                                                
                                                if participant.id != (viewModel.localUser?.id).orEmpty() {
                                                    Button(role: .destructive) {
                                                        viewModel.meeting.stage.kick(id: participant.id)
                                                    } label: {
                                                        Image.videoCallPutParticipant
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 24)
                                                        Text(LocalizableText.videoCallPutToViewer)
                                                        
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                                
                                                if participant.id != (viewModel.localUser?.id).orEmpty() {
                                                    Button(role: .destructive) {
                                                        isAlert.toggle()
                                                        
                                                    } label: {
                                                        Image.videoCallKickParticipantIcon
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 24)
                                                        Text(LocalizableText.videoCallKickFromSession)
                                                    }
                                                }
                                            } label: {
                                                Image.videoCallMenu
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 24)
                                            }
                                            .foregroundColor(.white)
                                            
                                        }
                                        
                                    }
                                    .alert(isPresented: $isAlert) { () -> Alert in
                                        Alert(title: Text(""), message: Text(LocalizableText.videoCallKickAlertFromSession), primaryButton: .default(Text(LocalizableText.videoCallKickAlertPrimaryButton)), secondaryButton: .default(Text(LocalizableText.videoCallKickAlertSecondaryButton), action: {
                                            viewModel.kickParticipant(participant)
                                        }))
                                }
                                }
                                .listRowSeparator(.hidden)

                            }
                        }
                        
                        .listRowSeparator(.hidden)
                    }
                    
                    
                    if !viewModel.meeting.stage.viewers.isEmpty {
                        Section(
                            header: HStack {
                                Text("\(LocalizableText.viewerTitle) (\(viewModel.meeting.stage.viewers.count))")
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                        ) {
                            ForEach(viewModel.meeting.stage.viewers, id: \.id) { participant in
                                HStack(spacing: 16) {
                                    ImageLoader(url: participant.picture.orEmpty(), width: 42, height: 42)
                                        .frame(width: 42, height: 42)
                                        .clipShape(Circle())
                                    
                                    Text(participant.name)
                                        .font(.robotoBold(size: 16))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        (participant.fetchAudioEnabled() ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24)
                                        
                                        (participant.fetchVideoEnabled() ? Image.videoCallVideoOnStrokeIcon : Image.videoCallVideoOffStrokeIcon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24)
                                        
                                        if viewModel.localUser?.canDoParticipantHostControls() ?? false {
                                            Menu {
                                                if participant.id != (viewModel.localUser?.id).orEmpty() {
                                                    Button {
                                                        viewModel.meeting.stage.grantAccess(id: participant.id)
                                                    } label: {
                                                        Image.videoCallPutToSpeaker
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 24)
                                                        Text(LocalizableText.videoCallPutToSpeaker)
                                                        
                                                    }
                                                }
                                                
                                                if participant.id != (viewModel.localUser?.id).orEmpty() {
                                                    Button(role: .destructive) {
                                                        isAlertPutToSpeaker.toggle()
                                                        
                                                    } label: {
                                                        Image.videoCallKickParticipantIcon
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 24)
                                                        Text(LocalizableText.videoCallKickFromSession)
                                                    }
                                                }
                                            } label: {
                                                Image.videoCallMenu
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 24)
                                            }
                                            .foregroundColor(.white)
                                        }
                                    }
                                    .alert(isPresented: $isAlertPutToSpeaker) {
                                        Alert(title: Text(""), message: Text(LocalizableText.videoCallKickAlertFromSession), primaryButton: .default(Text(LocalizableText.videoCallKickAlertPrimaryButton)), secondaryButton: .default(Text(LocalizableText.videoCallKickAlertSecondaryButton), action: {
                                            viewModel.kickParticipant(participant)
                                        }))
                                }
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(PlainListStyle())
                .onDisappear {
                    viewModel.hasNewParticipantRequest = false
                }
            }
        }
    }
    
    struct ChatView: View {
        @Environment(\.presentationMode) var presentationMode
        @State private var isFirstLoadComplete = false
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @State var shouldShowImagePicker = false
        @State var image: UIImage?
        
        var body: some View {
            VStack {
                //                MARK: Uncomment when the feature is ready
                //                HStack {
                //                    Image(systemName: "person.3")
                //                        .resizable()
                //                        .scaledToFit()
                //                        .frame(width: 24)
                //                        .foregroundColor(.white)
                //
                //                    Text("To Everyone")
                //                        .foregroundColor(.white)
                //                        .font(.system(size: 16))
                //
                //                    Spacer()
                //                    Button {
                //
                //                    } label: {
                //                        Image(systemName: "chevron.down")
                //                            .resizable()
                //                            .frame(width: 12, height: 7)
                //                            .foregroundColor(.white)
                //                    }
                //
                //                }
                //                .padding()
                //
                //                Divider()
                
                ScrollViewReader { scrollView in
                    VStack(spacing: 0) {
                        ScrollView {
                            LazyVStack {
                                ForEach(viewModel.meeting.chat.messages, id: \.self) { message in
                                    VStack(alignment: .leading, spacing: 9) {
                                        ChatHeaderView(
                                            author: message.displayName,
                                            isAuthorYou: message.userId == viewModel.localUserId,
                                            date: message.time
                                        )
                                        switch message.type {
                                        case .text:
                                            if let chat = message as? DyteTextMessage {
                                                ChatBubbleView(
                                                    messageBody: chat.message,
                                                    isAuthorYou: message.userId == viewModel.localUserId
                                                )
                                                /// Pin chat is not available in Dyte SDK
                                                //                                                .contextMenu {
                                                //                                                    Button {
                                                //                                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.4)) {
                                                //
                                                //                                                        }
                                                //                                                    } label: {
                                                //                                                        Label("Pin this chat", systemImage: "pin.fill")
                                                //                                                    }
                                                //                                                }
                                            }
                                        default:
                                            EmptyView()
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 7)
                                    .id(message)
                                    .onAppear {
                                        viewModel.hasNewMessage = false
                                    }
                                }
                                
                            }
                            
                        }
                        .onChange(of: viewModel.meeting.chat.messages) { value in
                            withAnimation {
                                scrollView.scrollTo(value.last, anchor: .bottom)
                            }
                        }
                        
                        HStack(alignment: .bottom) {
                            
                            HStack(alignment: .bottom) {
                                MultilineTextField(LocalizableText.videoCallMessagePlaceholder, text: $viewModel.messageText)
                                //                                Button(action: {
                                //
                                //                                }, label: {
                                //                                    Image(systemName: "link")
                                //                                        .foregroundColor(.white)
                                //                                })
                                //                                .padding(.vertical, 5)
                                //
                                //                                Button(action: {
                                //                                    shouldShowImagePicker.toggle()
                                //                                }, label: {
                                //                                    Image(systemName: "photo.on.rectangle.angled")
                                //                                        .foregroundColor(.white)
                                //                                })
                                //                                .padding(.vertical, 5)
                                
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.32, green: 0.34, blue: 0.36), lineWidth: 1)
                            )
                            
                            Button {
                                viewModel.sendMessage()
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(45))
                                    .frame(height: 18)
                            }
                            .padding(.vertical, 15)
                            .padding(.leading, 16)
                            .padding(.trailing, 22)
                            .background((viewModel.messageText.isEmpty || !viewModel.messageText.isStringContainWhitespaceAndText()) ? Color.dinotisGray : Color.DinotisDefault.primary)
                            .cornerRadius(11)
                            .disabled(viewModel.messageText.isEmpty || !viewModel.messageText.isStringContainWhitespaceAndText())
                            
                        }
                        .padding()
                    }
                    
                }
                /// Pin Chat is not available in Dyte SDK
                //                .overlay(alignment: .top) {
                //                    if let message = viewModel.pinnedChat {
                //                        VStack(alignment: .leading, spacing: 4) {
                //                            HStack {
                //                                Text((message.name))
                //                                    .font(.robotoMedium(size: 12))
                //                                    .foregroundColor(Color(red: 0.61, green: 0.62, blue: 0.62))
                //
                //                                Spacer()
                //
                //                                Button {
                //                                    withAnimation {
                //                                        viewModel.pinnedChat = nil
                //                                    }
                //                                } label: {
                //                                    Image(systemName: "pin.fill")
                //                                        .foregroundColor(Color(red: 0.61, green: 0.62, blue: 0.62))
                //                                }
                //                            }
                //
                //                            ChatBubbleView(messageBody: message.message, isAuthorYou: message.isYou)
                //                        }
                //                        .padding()
                //                        .overlay(
                //                            RoundedRectangle(cornerRadius: 6)
                //                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
                //                                .foregroundColor(.white)
                //                        )
                //                        .background(
                //                            RoundedRectangle(cornerRadius: 6)
                //                                .foregroundColor(Color(red: 0.15, green: 0.16, blue: 0.17))
                //                        )
                //                        .padding()
                //                        .transition(.move(edge: .top))
                //                    }
                //                }
            }
            .onAppear {
                viewModel.hasNewMessage = false
            }
        }
    }
    
    struct ChatHeaderView: View {
        let author: String
        let isAuthorYou: Bool
        let date: String
        
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter
        }()
        
        var body: some View {
            HStack {
                Text("\(author)\(isAuthorYou ? " (\(LocaleText.you))" : "")")
                    .lineLimit(1)
                Spacer()
                Text(date)
            }
            .foregroundColor(Color(red: 0.63, green: 0.64, blue: 0.66))
            .font(.robotoBold(size: 12))
        }
    }
    
    struct ChatBubbleView: View {
        let messageBody: String
        let isAuthorYou: Bool
        
        var body: some View {
            Text(messageBody)
                .font(.robotoRegular(size: 14))
                .foregroundColor(.white)
                .padding(10)
                .background(isAuthorYou ? Color.DinotisDefault.primary : Color(red: 0.26, green: 0.27, blue: 0.28))
                .cornerRadius(8)
                .multilineTextAlignment(.leading)
        }
    }
    
    
    struct PollingView: View {
        @State var isPollCard: Bool = false
        @State var fieldPoll: String = ""
        @State var isAdd: Bool = false
        @State var isPollCreated = false
        @State var addPoll = 0
        @State private var forms: [FormData] = []
        @State private var isCheckedOne: Bool = false
        @State private var isCheckedTwo: Bool = false
        
        var body: some View {
            GeometryReader {geo in
                ZStack {
                    Color.dinotisGray.ignoresSafeArea()
                    VStack(alignment: .leading) {
                        
                        if isPollCreated {
                            
                            VStack(alignment: .leading) {
                                Text(LocalizableText.videoCallPollByHost)
                                    .foregroundColor(.white)
                                    .font(.robotoBold(size: 16))
                                
                                VStack(alignment: .leading) {
                                    Text(fieldPoll)
                                        .foregroundColor(.white)
                                    ForEach(forms.indices, id: \.self) { index in
                                        PollFinish(form: $forms[index])
                                    }
                                }.padding()
                                    .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.grayChat))
                                    .frame(width: calculateContentWidth(geometry: geo))
                                
                            }.padding()
                            Spacer()
                            
                        } else {
                            Spacer()
                            if isPollCard {
                                //
                                ScrollView {
                                    VStack {
                                        Text(LocalizableText.videoCallPollQuestionTitle)
                                            .foregroundColor(.white)
                                            .padding(.top,10)
                                        
                                        if #available(iOS 16.0, *) {
                                            TextField("", text: $fieldPoll, axis: .vertical)
//                                                .placeholder(when: fieldPoll.isEmpty, placeholder: {
//                                                    Text(LocalizableText.videoCallPollQuestionPlaceholder).foregroundColor(.white)
//                                                })
                                                .autocorrectionDisabled(true)
                                                .lineLimit(3, reservesSpace: true)
                                                .padding(5)
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(UIApplication.shared.windows.first?.overrideUserInterfaceStyle == .dark ? Color.white : Color(.systemGray3), lineWidth: 1)
                                                        .background(Color.dinotisBgForm)
                                                }
                                                .padding()
                                        } else {
                                            // Fallback on earlier versions
                                        }
                                        
                                        ForEach(forms.indices, id: \.self) { index in
                                            FormRowView(form: $forms[index])
                                        }
                                        
                                        HStack {
                                            Button {
                                                isAdd.toggle()
                                                addForm()
                                                
                                            } label: {
                                                Image(systemName: "plus")
                                                    .resizable()
                                                    .frame(width: 10, height: 10)
                                                    .foregroundColor(.DinotisDefault.primary)
                                                Text(LocalizableText.videoCallPollAddOption)
                                                    .foregroundColor(.DinotisDefault.primary)
                                                
                                            }
                                            
                                        }
                                        
                                        
                                        VStack {
                                            Toggle(isOn: $isCheckedOne) {
                                                Text(LocalizableText.anonymousText)
                                            }
                                            .toggleStyle(CheckboxStyle())
                                            Toggle(isOn: $isCheckedTwo) {
                                                Text(LocalizableText.videoCallPollHideResult)
                                            }
                                            .toggleStyle(CheckboxStyle())
                                            
                                            
                                            
                                        }.padding(.trailing, 210)
                                        
                                        
                                        Button {
                                            isPollCreated.toggle()
                                        } label: {
                                            Text(LocalizableText.videoCallCreatePollTitle)
                                                .foregroundColor(Color.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.DinotisDefault.primary).cornerRadius(10)
                                                .border(Color.DinotisDefault.primary).cornerRadius(10)
                                        }
                                        .padding()
                                        //
                                        
                                    }
                                    .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.grayChat))
                                    .frame(width: calculateContentWidth(geometry: geo))
                                }
                                .padding()
                            }
                            
                            
                            VStack {
                                Text(LocalizableText.videoCallCreatePollFooter)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                
                                Button {
                                    isPollCard.toggle()
                                    
                                } label: {
                                    Text(isPollCard ? LocalizableText.videoCallCancelPollTitle : LocalizableText.videoCallCreateNewPollTitle)
                                        .foregroundColor(isPollCard ? Color.DinotisDefault.primary : Color.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(!isPollCard ? Color.DinotisDefault.primary : Color.clear).cornerRadius(10)
                                        .border(Color.DinotisDefault.primary).cornerRadius(10)
                                }.padding()
                                
                            }
                            
                        }
                        
                    }
                    
                    .frame(height: geo.size.height/1)
                    
                }
            }
        }
        
        private func addForm() {
            forms.append(FormData())
        }
        
        private func deleteForm(at indices: IndexSet) {
            forms.remove(atOffsets: indices)
        }
        
        private func calculateContentWidth(geometry: GeometryProxy) -> CGFloat {
            return geometry.size.width - 40
        }
        
    }
}

struct GroupVideoCallView_Previews: PreviewProvider {
    static var previews: some View {
        GroupVideoCallView(viewModel: GroupVideoCallViewModel(backToRoot: {}, backToHome: {}, userMeeting: .init(id: nil, title: nil, meetingDescription: nil, price: nil, startAt: nil, endAt: nil, isPrivate: nil, isLiveStreaming: nil, slots: nil, participants: nil, userID: nil, startedAt: nil, endedAt: nil, createdAt: nil, updatedAt: nil, deletedAt: nil, bookings: nil, user: nil, participantDetails: nil, meetingBundleId: nil, meetingRequestId: nil, status: nil, meetingRequest: nil, expiredAt: nil, background: nil, meetingCollaborations: nil, meetingUrls: nil, meetingUploads: nil, roomSid: nil, dyteMeetingId: nil)))
    }
}
