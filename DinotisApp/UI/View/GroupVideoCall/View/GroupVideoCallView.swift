//
//  GroupVideoCallView.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/23.
//

import AlertToast
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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.feedbackAfterCall,
                destination: { viewModel in
                    AftercallFeedbackView(viewModel: viewModel.wrappedValue)
                },
                onNavigate: {_ in},
                label: {
                    EmptyView()
                }
            )
            
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
            
            NavigationLink(
                unwrapping: $viewModel.route,
                case: /HomeRouting.setUpVideo,
                destination: { viewModel in
                    SetUpVideoView()
                        .environmentObject(viewModel.wrappedValue)
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
            
            LeaveSessionAlert()
                .environmentObject(viewModel)
                .isHidden(!viewModel.isShowLeavePopUp, remove: true)
            
            Color(red: 0.33, green: 0.33, blue: 0.33).opacity(0.75)
                .ignoresSafeArea()
                .isHidden(!viewModel.showGuide(), remove: !viewModel.showGuide())
            
            VStack(spacing: 16) {
                Image.feedbackSuccessImage
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                Text(LocalizableText.videoCallInteractionGuide)
                    .multilineTextAlignment(.center)
                    .font(.robotoRegular(size: 12))
                
                HStack {
                    Spacer()
                    
                    Button {
                        withAnimation {
                            viewModel.isShowInteractionGuide = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(LocalizableText.okText)
                                .font(.robotoBold(size: 12))
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
            .frame(maxWidth: 250)
            .background(
                Color.DinotisDefault.secondary
                    .cornerRadius(12)
            )
            .padding()
            .transition(.scale.animation(.spring(response: 0.4, dampingFraction: 0.6)))
            .isHidden(!viewModel.isShowInteractionGuide, remove: !viewModel.isShowInteractionGuide)

        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .toast(isPresenting: $viewModel.isShowRaisedToast, alert: {
            AlertToast(
                displayMode: .hud,
                type: .regular,
                maxWidth: UIScreen.main.bounds.width/1.2,
                subTitle: viewModel.toastText
            )
        })
        .onReceive(viewModel.didSendRequest, perform: {
            dismiss()
        })
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
                .dynamicTypeSize(.large)
        }
        .sheet(isPresented: $viewModel.isShowingQnA) {
            QnAListBottomSheet(viewModel: viewModel)
                .dynamicTypeSize(.large)
        }
        .sheet(isPresented: $viewModel.isShowQuestionBox) {
            if #available(iOS 16.0, *) {
                QuestionBoxBottomSheet(viewModel: viewModel)
                    .ignoresSafeArea(.all)
                    .presentationDetents([.height(360)])
                    .presentationDragIndicator(.hidden)
                    .dynamicTypeSize(.large)
            } else {
                QuestionBoxBottomSheet(viewModel: viewModel)
                    .dynamicTypeSize(.large)
            }
        }
        .sheet(isPresented: $viewModel.showingMoreMenu, content: {
            if #available(iOS 16.0, *) {
                MoreMenuSheet(viewModel: viewModel)
                    .presentationDetents([.height(230), .medium])
                    .presentationDragIndicator(.hidden)
                    .dynamicTypeSize(.large)
            } else {
                MoreMenuSheet(viewModel: viewModel)
                    .dynamicTypeSize(.large)
            }
        })
        .sheet(isPresented: $viewModel.isShowSessionInfo) {
            if #available(iOS 16.0, *) {
                SessionInfoBottomSheet(viewModel: viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
                    .dynamicTypeSize(.large)
            } else {
                SessionInfoBottomSheet(viewModel: viewModel)
                    .dynamicTypeSize(.large)
            }
        }
        .dinotisAlert(
            isPresent: $viewModel.isShowAlert,
            type: .videoCall,
            title: viewModel.alert.title,
            isError: false,
            message: viewModel.alert.message,
            primaryButton: viewModel.alert.primaryButton,
            secondaryButton: viewModel.alert.secondaryButton
        )
        .dinotisAlert(
            isPresent: $viewModel.isMeetingForceEnd,
            type: .videoCall,
            title: LocalizableText.attentionText,
            isError: false,
            message: LocalizableText.videoCallMeetingForceEnd,
            primaryButton: .init(text: LocalizableText.okText, action: {
                if viewModel.isJoined {
                    viewModel.leaveMeeting()
                } else {
                    viewModel.routeToAfterCall()
                }
            })
        )
        .dinotisAlert(
            isPresent: $viewModel.isDuplicate,
            type: .videoCall,
            title: LocalizableText.attentionText,
            isError: true,
            message: LocalizableText.groupVideoCallDuplicateAlert,
            primaryButton: .init(text: LocalizableText.groupVideoCallDisconnectNow, action: {
                viewModel.leaveMeeting()
            })
        )
        .overlayPreferenceValue(BoundsPreference.self) { value in
            if let preference = value.first(where: { item in
                item.key == viewModel.currentGuide?.rawValue
            }), let guide = viewModel.currentGuide {
                GeometryReader { proxy in
                    let rect = proxy[preference.value]
                    
                    Group {
                        switch guide {
                        case .viewerMode:
                            Button {
                                withAnimation {
                                    viewModel.isShowViewerModeGuide = true
                                    viewModel.currentGuide = .viewerMode
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image.videoCallHelpCircle
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 24)
                                    
                                    Text(LocalizableText.videoCallViewerMode)
                                        .font(.robotoMedium(size: 12))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .foregroundColor(Color(red: 0.28, green: 0.12, blue: 0.45))
                                )
                            }
                            .dinotisTooltip(
                                $viewModel.isShowViewerModeGuide,
                                alignment: .bottomTrailing,
                                id: VideoCallGuide.viewerMode.rawValue,
                                width: 180,
                                height: 92
                            ) {
                                VStack(alignment: .leading, spacing: 8) {
                                    
                                    if let text = try? AttributedString(markdown: LocalizableText.videoCallViewerModeGuide()) {
                                        Text(text)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.white)
                                            .font(.robotoRegular(size: 12))
                                    }
                                    
                                    HStack(spacing: 10) {
                                        Spacer()
                                        
                                        Button {
                                            withAnimation {
                                                viewModel.isShowViewerModeGuide = false
                                                viewModel.currentGuide = nil
                                            }
                                        } label: {
                                            Text(LocalizableText.okayWithDotLabel)
                                                .font(.robotoRegular(size: 12))
                                        }

                                        Button {
                                            withAnimation {
                                                if viewModel.meeting.participants.active.isEmpty {
                                                    viewModel.isShowViewerModeGuide = false
                                                    viewModel.currentGuide = nil
                                                } else {
                                                    viewModel.isShowViewerModeGuide = false
                                                    viewModel.isShowRaiseHandGuide = true
                                                    viewModel.currentGuide = .raiseHand
                                                }
                                            }
                                        } label: {
                                            HStack(spacing: 0) {
                                                Text(LocalizableText.showMeLabel)
                                                    .font(.robotoBold(size: 12))
                                                
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 12, weight: .bold))
                                            }
                                        }
                                    }
                                    .foregroundColor(.white)
                                }
                            }
                        case .raiseHand:
                            Button {
                                withAnimation(.spring()) {
                                    if viewModel.meeting.localUser.stageStatus == .onStage {
                                        viewModel.toggleMicrophone()
                                    } else {
                                        if viewModel.isRaised {
                                            viewModel.meeting.stage.cancelRequestAccess()
                                            viewModel.toastText = LocalizableText.videoCallUnraisedToast
                                        } else {
                                            viewModel.meeting.stage.requestAccess()
                                            viewModel.toastText = LocalizableText.videoCallRaisedToast
                                        }
                                        
                                        viewModel.isShowRaisedToast = true
                                        viewModel.isRaised = !viewModel.isRaised
                                    }
                                }
                            } label: {
                                if viewModel.meeting.localUser.stageStatus == .onStage {
                                    (viewModel.meeting.localUser.audioEnabled ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
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
                                            .frame(height: 32)
                                    }
                                }
                            }
                            .padding(6)
                            .background(
                                Color.DinotisDefault.black1
                                    .cornerRadius(16)
                            )
                            .dinotisTooltip(
                                $viewModel.isShowRaiseHandGuide,
                                alignment: .topLeading,
                                id: VideoCallGuide.raiseHand.rawValue,
                                width: 190,
                                height: 92,
                                context: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(LocalizableText.videoCallRaiseHandGuide)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.white)
                                            .font(.robotoRegular(size: 12))
                                        
                                        HStack(spacing: 10) {
                                            Spacer()
                                            
                                            Button {
                                                withAnimation {
                                                    viewModel.isShowRaiseHandGuide = false
                                                    viewModel.currentGuide = nil
                                                }
                                            } label: {
                                                Text(LocalizableText.okayWithDotLabel)
                                                    .font(.robotoRegular(size: 12))
                                            }

                                            Button {
                                                withAnimation {
                                                    viewModel.currentGuide = nil
                                                    viewModel.isShowRaiseHandGuide = false
                                                    viewModel.isShowInteractionGuide = true
                                                }
                                            } label: {
                                                HStack(spacing: 0) {
                                                    Text(LocalizableText.showMeLabel)
                                                        .font(.robotoBold(size: 12))
                                                    
                                                    Image(systemName: "chevron.right")
                                                        .font(.system(size: 12, weight: .bold))
                                                }
                                            }
                                        }
                                        .foregroundColor(.white)
                                    }
                                }
                            )
                        }
                    }
                    .frame(width: rect.width, height: rect.height)
                    .offset(x: rect.minX, y: rect.minY)
                }
            }
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
        @Namespace var indexView
        
        var body: some View {
            VStack {
                Spacer()
                    .frame(height: 60)
                    .isHidden(!viewModel.isShowingToolbar || !isPortrait, remove: !viewModel.isShowingToolbar || !isPortrait)
                
                //                Group {
                //                    switch viewModel.index {
                //                    case 0:
                //                        VStack {
                //                            if viewModel.screenShareUser.isEmpty {
                //
                //                                RemoteUserJoinedPrimaryVideoContainerView(viewModel: viewModel, participant: $viewModel.pinned)
                //                                    .padding(.horizontal)
                //                                    .padding(.bottom)
                //
                //                            } else {
                //                                ZStack(alignment: .top) {
                //
                //                                    RemoteScreenShareVideoContainerView(viewModel: viewModel, participant: $viewModel.screenShareId)
                //                                        .padding(.horizontal)
                //                                        .padding(.bottom)
                //
                //                                }
                //                            }
                //
                //                            Spacer()
                //                                .frame(height: 116)
                //                                .isHidden(!viewModel.isShowingToolbar || !isPortrait, remove: !viewModel.isShowingToolbar || !isPortrait)
                //                        }
                //                    default:
                //                        Group {
                //                            if viewModel.meeting.stage.onStage.isEmpty {
                //                                VStack(spacing: 15) {
                //                                    Spacer()
                //
                //                                    LottieView(name: "waiting-talent", loopMode: .loop)
                //                                        .scaledToFit()
                //                                        .frame(height: 225)
                //
                //                                    Text(LocalizableText.videoCallWaitingCreatorTitle)
                //                                        .font(.robotoBold(size: 22))
                //                                        .foregroundColor(.white)
                //                                        .multilineTextAlignment(.center)
                //
                //                                    Text(LocalizableText.videoCallWaitingCreatorSubtitle)
                //                                        .font(.robotoRegular(size: 14))
                //                                        .foregroundColor(.white)
                //                                        .multilineTextAlignment(.center)
                //
                //                                    Spacer()
                //                                }
                //                            } else {
                //                                ScrollView {
                //                                    LazyVStack {
                //                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 175))]) {
                //                                            ForEach($viewModel.participants, id: \.id) { item in
                //                                                RemoteUserJoinedTileVideoContainerView(viewModel: viewModel, participant: item)
                //                                            }
                //                                        }
                //                                    }
                //                                    .padding(15)
                //                                }
                //                            }
                //                        }
                //                    }
                //                }
                TabView(selection: $viewModel.index) {
                    if viewModel.pinned != nil || !viewModel.screenShareUser.isEmpty || viewModel.host != nil || viewModel.lastActive != nil {
                        VStack {
                            if viewModel.screenShareId != nil {
                                
                                RemoteScreenShareVideoContainerView(viewModel: viewModel, participant: $viewModel.screenShareId)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                
                            } else if viewModel.pinned != nil {
                                RemoteUserJoinedPrimaryVideoContainerView(viewModel: viewModel, participant: $viewModel.pinned)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                            } else if viewModel.host != nil {
                                RemoteUserJoinedPrimaryVideoContainerView(viewModel: viewModel, participant: $viewModel.host)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                            } else {
                                RemoteUserJoinedPrimaryVideoContainerView(viewModel: viewModel, participant: $viewModel.lastActive)
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
                            if viewModel.meeting.participants.active.isEmpty {
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
                                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                                            ForEach($viewModel.participants, id: \.id) { item in
                                                RemoteUserJoinedTileVideoContainerView(viewModel: viewModel, participant: item)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
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
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .overlay(
                            Capsule()
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
                                Button {
                                    withAnimation {
                                        viewModel.isShowViewerModeGuide = true
                                        viewModel.currentGuide = .viewerMode
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image.videoCallHelpCircle
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 24)
                                        
                                        Text(LocalizableText.videoCallViewerMode)
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .foregroundColor(Color(red: 0.28, green: 0.12, blue: 0.45))
                                    )
                                }
                                .dinotisTooltip(
                                    $viewModel.isShowViewerModeGuide,
                                    alignment: .bottomTrailing,
                                    id: VideoCallGuide.viewerMode.rawValue,
                                    width: 180,
                                    height: 92
                                ) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        if let text = try? AttributedString(markdown: LocalizableText.videoCallViewerModeGuide()) {
                                            Text(text)
                                                .multilineTextAlignment(.leading)
                                                .foregroundColor(.white)
                                                .font(.robotoRegular(size: 12))
                                        }
                                        
                                        HStack(spacing: 10) {
                                            Spacer()
                                            
                                            Button {
                                                
                                            } label: {
                                                Text(LocalizableText.okayWithDotLabel)
                                                    .font(.robotoRegular(size: 12))
                                            }

                                            Button {
                                                
                                            } label: {
                                                HStack(spacing: 0) {
                                                    Text(LocalizableText.showMeLabel)
                                                        .font(.robotoBold(size: 12))
                                                    
                                                    Image(systemName: "chevron.right")
                                                        .font(.system(size: 12, weight: .bold))
                                                }
                                            }
                                        }
                                        .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .isHidden(!viewModel.isShowingToolbar, remove: !viewModel.isShowingToolbar)
                    
                    Spacer()
                    
                    //                    if viewModel.isJoined {
                    //                        HStack {
                    //                            Button {
                    //                                if viewModel.pinned != nil || !viewModel.screenShareUser.isEmpty {
                    //                                    if viewModel.index > 0 {
                    //                                        viewModel.index -= 1
                    //                                    }
                    //                                } else {
                    //                                    if viewModel.index > 1 {
                    //                                        viewModel.index -= 1
                    //                                    }
                    //                                }
                    //                            } label: {
                    //                                Image(systemName: "chevron.left")
                    //                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    //                                    .foregroundColor(.white.opacity(!viewModel.meeting.participants.canGoPreviousPage ? 0.5 : 1))
                    //                                    .padding(.horizontal, 8)
                    //                                    .padding(.vertical, 18)
                    //                                    .background(
                    //                                        RoundedRectangle(cornerRadius: 8)
                    //                                            .foregroundColor(.DinotisDefault.black1.opacity(0.8))
                    //                                    )
                    //                            }
                    //
                    //                            Spacer()
                    //
                    //                            Button {
                    //                                if viewModel.index < viewModel.meeting.participants.pageCount-1 {
                    //                                    viewModel.index += 1
                    //                                }
                    //                            } label: {
                    //                                Image(systemName: "chevron.right")
                    //                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    //                                    .foregroundColor(.white.opacity(!viewModel.meeting.participants.canGoNextPage ? 0.5 : 1))
                    //                                    .padding(.horizontal, 8)
                    //                                    .padding(.vertical, 18)
                    //                                    .background(
                    //                                        RoundedRectangle(cornerRadius: 8)
                    //                                            .foregroundColor(.DinotisDefault.black1.opacity(0.8))
                    //                                    )
                    //                            }
                    //
                    //                        }
                    //                        .padding(10)
                    //                    }
                    
                    Spacer()
                        .onChange(of: viewModel.index) { idx in
                            if viewModel.pinned != nil || !viewModel.screenShareUser.isEmpty || viewModel.host != nil || viewModel.lastActive != nil {
                                if idx == 1 {
                                    viewModel.getTwoSecondTime()
                                    
                                } else {
                                    withAnimation(.spring()) {
                                        viewModel.mainLobbyTimer?.invalidate()
                                        viewModel.onSecondTime = 0
                                        self.viewModel.isLastPage = idx == 1
                                    }
                                }
                            }
                        }
                        .onChange(of: viewModel.onSecondTime) { time in
                            if viewModel.pinned != nil || !viewModel.screenShareUser.isEmpty || viewModel.host != nil || viewModel.lastActive != nil {
                                if viewModel.index == 1 {
                                    if time == 2 {
                                        withAnimation(.spring()) {
                                            self.viewModel.isLastPage = viewModel.index == 1
                                            viewModel.mainLobbyTimer?.invalidate()
                                            viewModel.onSecondTime = 0
                                        }
                                    }
                                }
                            }
                        }
                    
                    VStack {
                        Group {
                            if viewModel.isLastPage {
                                Button {
                                    withAnimation(.spring()) {
                                        viewModel.index = 0
                                    }
                                } label: {
                                    HStack(spacing: 5) {
                                        Text("\(Image(systemName: "arrow.backward")) \(LocalizableText.videoCallToMain)")
                                            .font(.robotoMedium(size: 12))
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: 60, maxHeight: 30)
                                    .padding(.horizontal, 10)
                                    .background(
                                        Capsule()
                                            .foregroundColor(Color(red: 0.15, green: 0.16, blue: 0.17).opacity(0.8))
                                    )
                                }

                            } else {
                                HStack(spacing: 5) {
                                    if viewModel.pinned != nil || !viewModel.screenShareUser.isEmpty || viewModel.host != nil || viewModel.lastActive != nil {
                                        ForEach(0...1, id: \.self) { index in
                                            Circle()
                                                .scaledToFit()
                                                .frame(width: viewModel.index == index ? 6 : 4)
                                                .foregroundColor(viewModel.index == index ? .DinotisDefault.primary : .gray)
                                                .matchedGeometryEffect(id: index, in: indexView)
                                        }
                                    } else {
                                        Circle()
                                            .scaledToFit()
                                            .frame(width: 6)
                                            .foregroundColor(.DinotisDefault.primary)
                                    }
                                }
                                .frame(maxWidth: 40, maxHeight: 30)
                                .padding(.horizontal, 10)
                                .background(
                                    Capsule()
                                        .foregroundColor(Color(red: 0.15, green: 0.16, blue: 0.17).opacity(0.8))
                                )
                            }
                        }
//                        .onChange(of: viewModel.index) { item in
//                            if item == 1 && (viewModel.pinned != nil || !viewModel.screenShareUser.isEmpty || viewModel.host != nil || viewModel.lastActive != nil) {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                    viewModel.isLastPage = true
//                                }
//                            } else {
//                                viewModel.isLastPage = false
//                            }
//                        }

//                        ScrollViewReader { scroll in
//                            HStack {
//                                Spacer()
//
//                                LazyHStack {
//                                    ScrollView(.horizontal, showsIndicators: false) {
//                                        LazyHStack(spacing: 5) {
//                                            if viewModel.pinned != nil || !viewModel.screenShareUser.isEmpty {
//                                                ForEach(0...1, id: \.self) { index in
//                                                    Circle()
//                                                        .scaledToFit()
//                                                        .frame(width: viewModel.index == index ? 6 : 4)
//                                                        .foregroundColor(viewModel.index == index ? .DinotisDefault.primary : .gray)
////                                                        .tag(index)
//                                                }
//                                            } else {
//                                                //                                                if viewModel.meeting.participants.pageCount == 1 {
//                                                ForEach(1...1, id: \.self) { index in
//                                                    Circle()
//                                                        .scaledToFit()
//                                                        .frame(width: viewModel.index == index ? 6 : 4)
//                                                        .foregroundColor(viewModel.index == index ? .DinotisDefault.primary : .gray)
////                                                        .tag(1)
//                                                }
//                                                //                                                } else {
//                                                //                                                    ForEach(1...2, id: \.self) { index in
//                                                //                                                        Circle()
//                                                //                                                            .scaledToFit()
//                                                //                                                            .frame(width: viewModel.index == index ? 6 : 4)
//                                                //                                                            .foregroundColor(viewModel.index == index ? .DinotisDefault.primary : .gray)
//                                                //                                                            .tag(index)
//                                                //                                                    }
//                                                //                                                }
//                                            }
//                                        }
//                                        //                                        .onChange(of: viewModel.index) { item in
//                                        //                                            withAnimation(.spring()) {
//                                        //                                                scroll.scrollTo(item)
//                                        //                                            }
//                                        //                                        }
//
//                                    }
//                                    .frame(maxWidth: 35, maxHeight: 30)
//                                }
//                                Spacer()
//                            }
//                            .frame(maxWidth: 40, maxHeight: 30)
//                            .padding(.horizontal, 10)
//                            .background(
//                                Capsule()
//                                    .foregroundColor(Color(red: 0.15, green: 0.16, blue: 0.17).opacity(0.8))
//                            )
//                        }
                    }
                    .padding(.bottom, viewModel.isShowingToolbar ? 0 : 24)
                    
                    BottomToolBar(viewModel: viewModel)
                        .isHidden(!viewModel.isShowingToolbar, remove: !viewModel.isShowingToolbar)
                }
                .padding(.bottom, 10)
                .edgesIgnoringSafeArea(.bottom)
            }
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
                                (viewModel.meeting.localUser.videoEnabled ? Image.videoCallVideoOnStrokeIcon : Image.videoCallVideoOffStrokeIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .foregroundColor(Color(red: 0.21, green: 0.22, blue: 0.22))
                                    )
                                    .frame(width: 48, height: 48)
                            }
                            
                            if !viewModel.isReceivedStageInvite {
                                Button {
                                    viewModel.toggleMicrophone()
                                } label: {
                                    (viewModel.meeting.localUser.audioEnabled ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
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
                                        (viewModel.meeting.localUser.videoEnabled ? Image.videoCallVideoOnStrokeIcon : Image.videoCallVideoOffStrokeIcon)
                                            .resizable()
                                            .scaledToFit()
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .foregroundColor(Color(red: 0.21, green: 0.22, blue: 0.22))
                                            )
                                            .frame(width: 48, height: 48)
                                    }
                                    
                                    if !viewModel.isReceivedStageInvite {
                                        Button {
                                            viewModel.toggleMicrophone()
                                        } label: {
                                            (viewModel.meeting.localUser.audioEnabled ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
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
                                    if self.viewModel.meeting.localUser.canDoParticipantHostControls() {
                                        self.viewModel.isShowingQnA.toggle()
                                    } else {
                                        self.viewModel.isShowQuestionBox.toggle()
                                    }
                                }
                            } label: {
                                HStack(alignment: .center, spacing: 11) {
                                    ZStack(alignment: .topTrailing, content: {
                                        Image.videoCallQuestionIcon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24)
                                        
                                        if viewModel.hasNewQuestion && viewModel.meeting.localUser.canDoParticipantHostControls() {
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
                                .padding(10)
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
                                    .frame(width: 24)
                                
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
                            .padding(10)
                            .contentShape(Rectangle())
                        }
//                        .isHidden(true, remove: true)
                        
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
                                        .frame(width: 24)
                                    
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
                            .padding(10)
                            .contentShape(Rectangle())
                        }
                        
                        if viewModel.meeting.localUser.canDoParticipantHostControls() {
                            Button {
                                
                            } label: {
                                HStack(alignment: .center, spacing: 11) {
                                    Image.videoCallRecordVideoIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24)
                                    
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
                                .padding(10)
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
                                    .frame(width: 24)
                                
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
                            .padding(10)
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
                                viewModel.toastText = LocalizableText.videoCallUnraisedToast
                            } else {
                                viewModel.meeting.stage.requestAccess()
                                viewModel.toastText = LocalizableText.videoCallRaisedToast
                            }
                            
                            viewModel.isShowRaisedToast = true
                            viewModel.isRaised = !viewModel.isRaised
                        }
                    }
                } label: {
                    if viewModel.meeting.localUser.stageStatus == .onStage {
                        (viewModel.meeting.localUser.audioEnabled ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
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
                                .frame(height: 32)
                        }
                    }
                }
                .padding(6)
                .dinotisTooltip(
                    $viewModel.isShowRaiseHandGuide,
                    alignment: .topLeading,
                    id: VideoCallGuide.raiseHand.rawValue,
                    width: 190,
                    height: 92,
                    context: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizableText.videoCallRaiseHandGuide)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.white)
                                .font(.robotoRegular(size: 12))
                            
                            HStack(spacing: 10) {
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        viewModel.isShowRaiseHandGuide = false
                                        viewModel.currentGuide = nil
                                    }
                                } label: {
                                    Text(LocalizableText.okayWithDotLabel)
                                        .font(.robotoRegular(size: 12))
                                }

                                Button {
                                    withAnimation {
                                        viewModel.isShowRaiseHandGuide = false
                                        viewModel.isShowRaiseHandGuide = true
                                    }
                                } label: {
                                    HStack(spacing: 0) {
                                        Text(LocalizableText.showMeLabel)
                                            .font(.robotoBold(size: 12))
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                }
                            }
                            .foregroundColor(.white)
                        }
                    }
                )
                .isHidden(viewModel.meeting.participants.active.isEmpty, remove: viewModel.meeting.participants.active.isEmpty)
                
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
                        (viewModel.meeting.localUser.videoEnabled ? Image.videoCallVideoOnStrokeIcon : Image.videoCallVideoOffStrokeIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 32)
                    } else {
                        ZStack(alignment: .topTrailing) {
                            Image.videoCallChatIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32)
                                .foregroundColor(.white)
                            
                            if viewModel.hasNewMessage {
                                Circle()
                                    .foregroundColor(.red)
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                }
                .padding(.horizontal, 6)
                
                Button {
                    if viewModel.meeting.localUser.stageStatus == .onStage {
                        viewModel.tabSelection = 0
                        viewModel.isShowAboutCallBottomSheet.toggle()
                    } else {
                        viewModel.isShowQuestionBox.toggle()
                    }
                } label: {
                    if viewModel.meeting.localUser.stageStatus == .onStage {
                        ZStack(alignment: .topTrailing) {
                            Image.videoCallChatIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32)
                                .foregroundColor(.white)
                                .overlay(alignment: .topTrailing) {
                                    if viewModel.hasNewMessage {
                                        Circle()
                                            .foregroundColor(.red)
                                            .frame(width: 10, height: 10)
                                    }
                                }
                        }
                        
                    } else {
                        Image.videoCallQuestionIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32)
                    }
                }
                .padding(.horizontal, 6)
                
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
                                .frame(height: 32)
                        }
                        
                        if (viewModel.hasNewQuestion || viewModel.hasNewParticipantRequest) && viewModel.meeting.localUser.canDoParticipantHostControls() {
                            Circle()
                                .foregroundColor(.red)
                                .scaledToFit()
                                .frame(width: 10)
                        }
                    }
                }
                .padding(.horizontal, 6)
                
                Button {
                    withAnimation(.spring()) {
                        viewModel.isShowLeavePopUp.toggle()
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
                .padding(.horizontal, 6)
                .disabled(!viewModel.isJoined)
                
            }
            .padding()
            .padding(.horizontal, 6)
            .background(Color.DinotisDefault.black1.opacity(0.8).blur(radius: 0.8))
            .cornerRadius(24)
            .padding(.horizontal, 20)
            .padding(.bottom)
        }
    }
    
    struct LocalUserVideoContainerView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                    if viewModel.isCameraOn {
                        if let video = viewModel.meeting.localUser.getVideoView() {
                            UIVideoView(videoView: video, width: .infinity, height: .infinity)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .rotationEffect(.degrees(0))
                                .rotation3DEffect(.degrees(viewModel.position == .rear ? 180 : 0), axis: (0, 1, 0))
                        }
                        
                    } else {
                        if viewModel.meeting.localUser.picture == nil {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                                .overlay(
                                    Text(viewModel.createInitial((viewModel.meeting.localUser.picture).orEmpty()))
                                        .font(.robotoRegular(size: 20))
                                        .foregroundColor(.white)
                                        .background(
                                            Circle()
                                                .frame(width: 120, height: 120)
                                                .foregroundColor(.DinotisDefault.primary)
                                        )
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 14)
                                .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .overlay(
                                    ImageLoader(url: (viewModel.meeting.localUser.picture).orEmpty(), width: .infinity, height: .infinity)
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                )
                        }
                    }
                
                    HStack(spacing: 0) {
                        (
                            viewModel.meeting.localUser.audioEnabled ?
                            Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                        
                        Text(" \(viewModel.meeting.localUser.name) \(viewModel.userType(preset: viewModel.meeting.localUser.presetName))")
                            .font(.robotoMedium(size: 10))
                            .lineLimit(1)
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
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    struct RemoteUserJoinedTileVideoContainerView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Binding var participant: DyteJoinedMeetingParticipant
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                if viewModel.index == 0 && ((viewModel.pinned?.id).orEmpty() == participant.id || (viewModel.host?.id).orEmpty() == participant.id || (viewModel.lastActive?.id).orEmpty() == participant.id) {
                    if viewModel.pinned == nil && viewModel.screenShareUser.isEmpty && viewModel.host == nil && viewModel.lastActive == nil {
                        if participant.videoEnabled {
                            if let video = participant.getVideoView() {
                                UIVideoView(videoView: video, width: .infinity, height: 270)
                                    .frame(height: 270)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                        } else {
                            if participant.picture == nil {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                                    .frame(height: 270)
                                    .overlay(
                                        Text(viewModel.createInitial(participant.name))
                                            .font(.robotoRegular(size: 20))
                                            .foregroundColor(.white)
                                            .background(
                                                Circle()
                                                    .frame(width: 120, height: 120)
                                                    .foregroundColor(.DinotisDefault.primary)
                                            )
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                                    .frame(height: 270)
                                    .overlay(
                                        ImageLoader(url: participant.picture.orEmpty(), width: 120, height: 120)
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                    )
                            }
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                            .frame(width: 175, height: 270)
                    }
                    
                } else {
                    if participant.videoEnabled {
                        if let video = participant.getVideoView() {
                            UIVideoView(videoView: video, width: .infinity, height: 270)
                                .frame(height: 270)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                    } else {
                        if participant.picture == nil {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                                .frame(height: 270)
                                .overlay(
                                    Text(viewModel.createInitial(participant.name))
                                        .font(.robotoRegular(size: 20))
                                        .foregroundColor(.white)
                                        .background(
                                            Circle()
                                                .frame(width: 120, height: 120)
                                                .foregroundColor(.DinotisDefault.primary)
                                        )
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                                .frame(height: 270)
                                .overlay(
                                    ImageLoader(url: participant.picture.orEmpty(), width: 120, height: 120)
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                )
                        }
                    }
                }
                
                HStack(spacing: 0) {
                    (
                        participant.audioEnabled ?
                        Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12)
                    
                    if participant.isPinned {
                        Text(" \(Image(systemName: "pin")) \(participant.name) \(viewModel.userType(preset: participant.presetName))")
                            .font(.robotoMedium(size: 10))
                            .lineLimit(1)
                            .foregroundColor(.white)
                    } else {
                        Text(" \(participant.name) \(viewModel.userType(preset: participant.presetName))")
                            .font(.robotoMedium(size: 10))
                            .lineLimit(1)
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
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    struct RemoteUserJoinedPrimaryVideoContainerView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Binding var participant: DyteJoinedMeetingParticipant?
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                if viewModel.index == 1 && (viewModel.meeting.localUser.id == (participant?.id).orEmpty() || viewModel.pinned?.id == participant?.id || viewModel.host?.id == participant?.id || viewModel.lastActive?.id == participant?.id) {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                } else {
                    if participant?.videoEnabled ?? false {
                        if let video = participant?.getVideoView() {
                            UIVideoView(videoView: video, width: .infinity, height: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                    } else {
                        if participant?.picture == nil {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                                .overlay(
                                    Text(viewModel.createInitial((participant?.name).orEmpty()))
                                        .font(.robotoRegular(size: 20))
                                        .foregroundColor(.white)
                                        .background(
                                            Circle()
                                                .frame(width: 120, height: 120)
                                                .foregroundColor(.DinotisDefault.primary)
                                        )
                                )
                        } else {
                            if participant?.picture == nil {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                                    .overlay(
                                        Text(viewModel.createInitial((participant?.name).orEmpty()))
                                            .font(.robotoRegular(size: 20))
                                            .foregroundColor(.white)
                                            .background(
                                                Circle()
                                                    .frame(width: 120, height: 120)
                                                    .foregroundColor(.DinotisDefault.primary)
                                            )
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                                    .overlay(
                                        ImageLoader(url: (participant?.picture).orEmpty(), width: 120, height: 120)
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                    )
                            }
                        }
                    }
                }
                
                HStack(spacing: 0) {
                    (
                        (participant?.audioEnabled ?? false) ?
                        Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12)
                    
                    if participant?.isPinned ?? false {
                        Text(" \(Image(systemName: "pin")) \((participant?.name).orEmpty()) \(viewModel.userType(preset: (participant?.presetName).orEmpty()))")
                            .font(.robotoMedium(size: 10))
                            .lineLimit(1)
                            .foregroundColor(.white)
                    } else {
                        Text(" \((participant?.name).orEmpty()) \(viewModel.userType(preset: (participant?.presetName).orEmpty()))")
                            .font(.robotoMedium(size: 10))
                            .lineLimit(1)
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
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    struct RemoteUserJoinedFlexibleVideoContainerView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Binding var participant: DyteJoinedMeetingParticipant
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                if viewModel.index == 0 && ((viewModel.pinned?.id).orEmpty() == participant.id || (viewModel.host?.id).orEmpty() == participant.id || (viewModel.lastActive?.id).orEmpty() == participant.id) {
                    if viewModel.pinned == nil && viewModel.screenShareUser.isEmpty && viewModel.host == nil && viewModel.lastActive == nil {
                        if participant.videoEnabled {
                            if let video = participant.getVideoView() {
                                UIVideoView(videoView: video, width: .infinity, height: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                        } else {
                            if participant.picture == nil {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                                    .overlay(
                                        Text(viewModel.createInitial(participant.name))
                                            .font(.robotoRegular(size: 20))
                                            .foregroundColor(.white)
                                            .background(
                                                Circle()
                                                    .frame(width: 120, height: 120)
                                                    .foregroundColor(.DinotisDefault.primary)
                                            )
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                                    .overlay(
                                        ImageLoader(url: participant.picture.orEmpty(), width: 120, height: 120)
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                    )
                            }
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                    }
                    
                } else {
                    if participant.videoEnabled {
                        if let video = participant.getVideoView() {
                            UIVideoView(videoView: video, width: .infinity, height: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(red: 0.1, green: 0.11, blue: 0.12))
                            .overlay(
                                ImageLoader(url: participant.picture.orEmpty(), width: 120, height: 120)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            )
                    }
                }
                
                HStack(spacing: 0) {
                    (
                        participant.audioEnabled ?
                        Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12)
                    
                    if participant.isPinned {
                        Text(" \(Image(systemName: "pin")) \(participant.name) \(viewModel.userType(preset: participant.presetName))")
                            .font(.robotoMedium(size: 10))
                            .lineLimit(1)
                            .foregroundColor(.white)
                    } else {
                        Text(" \(participant.name) \(viewModel.userType(preset: participant.presetName))")
                            .font(.robotoMedium(size: 10))
                            .lineLimit(1)
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
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    struct RemoteScreenShareVideoContainerView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Binding var participant: DyteJoinedMeetingParticipant?
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                if viewModel.index == 0 && viewModel.meeting.localUser.id == (participant?.id).orEmpty() {
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
                        (participant?.audioEnabled ?? false) ?
                        Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon
                    )
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12)
                    
                    Text(" \(participant?.name ?? "") (\(LocalizableText.videoCallScreenShareText)")
                        .font(.robotoMedium(size: 10))
                        .lineLimit(1)
                        .foregroundColor(.white)
                }
                .padding(5)
                .background(
                    Capsule()
                        .foregroundColor(.gray.opacity(0.5))
                )
                .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    struct AboutCallBottomSheet: View {
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Environment(\.dismiss) var dismiss
        @Namespace var namespace
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text(LocalizableText.aboutCallTitle)
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
                    case 2:
                        PollingView()
                            .environmentObject(viewModel)
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
        @Environment(\.dismiss) var dismiss
        @Namespace var namespace
        
        var body: some View {
            VStack(alignment: .leading) {
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(LocalizableText.videoCallListQuestionTitle)
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
                                                Task {
                                                   await viewModel.putQuestion(item: item)
                                                }
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
                            Task {
                              await viewModel.getQuestion()
                            }
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
                                Task {
                                   await viewModel.getQuestion()
                                }
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
                                            Task {
                                               await viewModel.putQuestion(item: item)
                                            }
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
        @Environment(\.dismiss) var dismiss
        @FocusState var editorFocused: Bool
        
        var body: some View {
            GeometryReader { _ in
                LazyVStack(spacing: 14) {
                    HStack {
                        Text(LocalizableText.videoCallBoxQuestionTitle)
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
                    
                    ZStack(alignment: .topLeading) {
#if os(macOS)
                        TextEditor(text: $viewModel.questionText)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.white)
                            .textFieldStyle(.plain)
                            .frame(height: 190)
                            .textEditorBackground(Color(red: 0.18, green: 0.19, blue: 0.2))
                            .focused($editorFocused)
#else
                        TextEditor(text: $viewModel.questionText)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.white)
                            .textFieldStyle(.plain)
                            .frame(height: 190)
                            .textEditorBackground(Color(red: 0.18, green: 0.19, blue: 0.2))
                            .focused($editorFocused)
#endif
                        
                        if viewModel.questionText.isEmpty && !editorFocused {
                            Text(LocalizableText.videoCallPollQuestionPlaceholder)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.DinotisDefault.black3)
                                .padding(4)
                                .padding(.top, 4)
                                .onTapGesture {
                                    editorFocused = true
                                }
                        }
                    }
                    .tint(.DinotisDefault.primary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(red: 0.18, green: 0.19, blue: 0.2))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    
                    Button {
                        Task {
                            await viewModel.sendQuestion(meetingId: viewModel.userMeeting.id.orEmpty())
                        }
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
                        .background((viewModel.questionText.isEmpty || !viewModel.questionText.isStringContainWhitespaceAndText()) ? Color.dinotisGray.ignoresSafeArea() : Color.DinotisDefault.primary.ignoresSafeArea())
                        .cornerRadius(11)
                        .disabled(viewModel.questionText.isEmpty || !viewModel.questionText.isStringContainWhitespaceAndText())
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    if #available(iOS 16.0, *) {
                        EmptyView()
                    } else {
                        Spacer()
                    }
                }
            }
            .background(Color(red: 0.15, green: 0.16, blue: 0.17).ignoresSafeArea())
            .ignoresSafeArea()
        }
    }
    
    struct QnARowView: View {
        
        @State var data: QuestionData
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
                    if viewModel.meeting.localUser.canDoParticipantHostControls() {
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
                                        if participant.picture == nil {
                                            Circle()
                                                .frame(width: 42, height: 42)
                                                .foregroundColor(.DinotisDefault.primary)
                                                .overlay(
                                                    Text(viewModel.createInitial(participant.name))
                                                        .font(.robotoRegular(size: 14))
                                                        .foregroundColor(.white)
                                                )
                                                .padding(.horizontal)
                                        } else {
                                            ImageLoader(url: participant.picture.orEmpty(), width: 42, height: 42)
                                                .frame(width: 42, height: 42)
                                                .clipShape(Circle())
                                        }
                                        
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
                                        if participant.picture == nil {
                                            Circle()
                                                .frame(width: 42, height: 42)
                                                .foregroundColor(.DinotisDefault.primary)
                                                .overlay(
                                                    Text(viewModel.createInitial(participant.name))
                                                        .font(.robotoRegular(size: 14))
                                                        .foregroundColor(.white)
                                                )
                                        } else {
                                            ImageLoader(url: participant.picture.orEmpty(), width: 42, height: 42)
                                                .frame(width: 42, height: 42)
                                                .clipShape(Circle())
                                        }
                                        
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
                    
                    if !viewModel.meeting.participants.active.isEmpty {
                        Section(
                            header: HStack {
                                Text("\(LocalizableText.speakerTitle) (\(viewModel.meeting.participants.active.count))")
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                        ) {
                            ForEach(viewModel.meeting.participants.active, id: \.id) { participant in
                                HStack(spacing: 16) {
                                    if participant.picture == nil {
                                        Circle()
                                            .frame(width: 42, height: 42)
                                            .foregroundColor(.DinotisDefault.primary)
                                            .overlay(
                                                Text(viewModel.createInitial(participant.name))
                                                    .font(.robotoRegular(size: 14))
                                                    .foregroundColor(.white)
                                            )
                                    } else {
                                        ImageLoader(url: participant.picture.orEmpty(), width: 42, height: 42)
                                            .frame(width: 42, height: 42)
                                            .clipShape(Circle())
                                    }
                                    
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
                                        (participant.audioEnabled ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24)

                                        (participant.videoEnabled ? Image.videoCallVideoOnStrokeIcon : Image.videoCallVideoOffStrokeIcon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24)
                                        
                                        if viewModel.meeting.localUser.canDoParticipantHostControls() {
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
                                                if participant.id != viewModel.meeting.localUser.id {
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
                                                if participant.id != viewModel.meeting.localUser.id {
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
                                                
                                                if participant.id != viewModel.meeting.localUser.id {
                                                    Button(role: .destructive) {
                                                        viewModel.meeting.stage.kick(id: participant.id)
                                                    } label: {
                                                        Image.videoCallPutParticipant
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 24)
                                                        Text(LocalizableText.videoCallPutToViewer)
                                                        
                                                    }
                                                }
                                                
                                                if participant.id != viewModel.meeting.localUser.id {
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
                                    if participant.picture == nil {
                                        Circle()
                                            .frame(width: 42, height: 42)
                                            .foregroundColor(.DinotisDefault.primary)
                                            .overlay(
                                                Text(viewModel.createInitial(participant.name))
                                                    .font(.robotoRegular(size: 14))
                                                    .foregroundColor(.white)
                                            )
                                    } else {
                                        ImageLoader(url: participant.picture.orEmpty(), width: 42, height: 42)
                                            .frame(width: 42, height: 42)
                                            .clipShape(Circle())
                                    }
                                    
                                    Text(participant.name)
                                        .font(.robotoBold(size: 16))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        if participant.stageStatus == .requestedToJoinStage {
                                            HStack(spacing: 5) {
                                                Image.videoCallNeutralRaiseHand
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 20)
                                                    .foregroundColor(.DinotisDefault.black1)
                                                
                                                Text(LocalizableText.videoCallRaiseHand)
                                                    .font(.robotoMedium(size: 12))
                                                    .foregroundColor(.DinotisDefault.black1)
                                            }
                                            .padding(.vertical, 5)
                                            .padding(.horizontal, 10)
                                            .background(
                                                Capsule()
                                                    .foregroundColor(.white)
                                            )
                                        } else {
                                            (participant.audioEnabled ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24)
                                            
                                            (participant.videoEnabled ? Image.videoCallVideoOnStrokeIcon : Image.videoCallVideoOffStrokeIcon)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24)
                                        }
                                        
                                        if viewModel.meeting.localUser.canDoParticipantHostControls() {
                                            Menu {
                                                if participant.id != viewModel.meeting.localUser.id {
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
                                                
                                                if participant.id != viewModel.meeting.localUser.id {
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
        @Environment(\.dismiss) var dismiss
        @State private var isFirstLoadComplete = false
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @State var shouldShowImagePicker = false
        @State var image: UIImage?
        @State private var previousHeader: (author: String, date: String)? = nil

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
                            VStack {
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
                                        .padding(.vertical, 5)
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
                        .onAppear(perform: {
                            scrollView.scrollTo(viewModel.meeting.chat.messages.last)
                        })
                        
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
                                    .padding(.vertical, 15)
                                    .padding(.leading, 16)
                                    .padding(.trailing, 22)
                                    .background((viewModel.messageText.isEmpty || !viewModel.messageText.isStringContainWhitespaceAndText()) ? Color.dinotisGray : Color.DinotisDefault.primary)
                                    .cornerRadius(11)
                            }
                            .contentShape(RoundedRectangle(cornerRadius: 11))
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
            Text(messageBody.containURL(whiteText: isAuthorYou, size: 14))
                .font(.robotoRegular(size: 14))
                .foregroundColor(.white)
                .padding(10)
                .background(isAuthorYou ? Color.DinotisDefault.primary : Color(red: 0.26, green: 0.27, blue: 0.28))
                .cornerRadius(8)
                .multilineTextAlignment(.leading)
        }
    }
    
    
    struct PollingView: View {
        @EnvironmentObject var viewModel: GroupVideoCallViewModel
        
        var body: some View {
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        if viewModel.meeting.localUser.canDoParticipantHostControls(),
                           viewModel.isCreatePoll {
                            PollingFormView()
                        } else {
                            if viewModel.meeting.polls.polls.isEmpty {
                                Text(LocalizableText.videoCallEmptyPollingDesc)
                                    .font(.robotoRegular(size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .padding(.top, 70)
                            } else {
                                HStack {
                                    Text(LocalizableText.videoCallPollByHost)
                                        .font(.robotoBold(size: 14))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Button {
                                        withAnimation {
                                            viewModel.isCreatePoll = true
                                        }
                                    } label: {
                                        Text("\(Image(systemName: "plus")) \(LocalizableText.morePollingLabel)")
                                            .font(.robotoBold(size: 14))
                                            .foregroundColor(.white)
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(.DinotisDefault.primary)
                                            )
                                    }
                                    .isHidden(!viewModel.meeting.localUser.canDoParticipantHostControls(), remove: true)
                                }
                                .padding()
                                
                                ForEach(viewModel.meeting.polls.polls.indices, id: \.self) { index in
                                    let poll = viewModel.meeting.polls.polls[index]
                                    ZStack {
                                        VStack(alignment: .leading, spacing: 16) {
                                            Text("\(LocalizableText.pollLabel) \(index+1)")
                                                .font(.robotoBold(size: 12))
                                                .foregroundColor(.DinotisDefault.primary)
                                                .padding(.vertical, 5)
                                                .padding(.horizontal, 14)
                                                .background(
                                                    Capsule()
                                                        .foregroundColor(Color(red: 0.89, green: 0.77, blue: 1))
                                                )
                                            
                                            Text(poll.question)
                                                .font(.robotoRegular(size: 12))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            VStack(spacing: 0) {
                                                ForEach(poll.options.indices, id:\.self) { optionIndex in
                                                    let option = poll.options[optionIndex]
                                                    
                                                    Button {
                                                        viewModel.isLoadingVoted[index] = true
                                                        viewModel.meeting.polls.vote(pollMessage: poll, pollOption: option)
                                                    } label: {
                                                        HStack(spacing: 4) {
                                                            Image(
                                                                systemName: option.votes.contains(where: {
                                                                    $0.id.contains(viewModel.meeting.localUser.userId)
                                                                }) ? "checkmark.square.fill" : "square.fill"
                                                            )
                                                            .foregroundColor(
                                                                option.votes.contains(where: {
                                                                    $0.id.contains(viewModel.meeting.localUser.userId)
                                                                }) ? .white : .DinotisDefault.black3.opacity(0.5)
                                                            )
                                                            .font(.system(size: 18))
                                                            
                                                            Text(option.text)
                                                                .font(.robotoRegular(size: 12))
                                                                .foregroundColor(.white)
                                                                .multilineTextAlignment(.leading)
                                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                        }
                                                        .padding(8)
                                                        .padding(.vertical, 8)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .foregroundColor(
                                                                    option.votes.contains(where: {
                                                                        $0.name.contains(viewModel.meeting.localUser.name)
                                                                    }) ? .DinotisDefault.primary : .clear
                                                                )
                                                        )
                                                    }
                                                }
                                            }
                                            .disabled(poll.options.contains(where: { $0.votes.contains {
                                                $0.id.contains(viewModel.meeting.localUser.userId)
                                            } }))
                                            
                                            Divider()
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("\(LocalizableText.resultLabel):")
                                                    .font(.robotoBold(size: 12))
                                                    .foregroundColor(.white)
                                                    .padding(.bottom, 2)
                                                
                                                ForEach(poll.options.indices, id: \.self) { option in
                                                    HStack(spacing: 8) {
                                                        Circle()
                                                            .foregroundColor(.DinotisDefault.primary)
                                                            .frame(width: 9, height: 9)
                                                        
                                                        Text(poll.options[option].text)
                                                            .font(.robotoRegular(size: 12))
                                                            .foregroundColor(.white)
                                                            .multilineTextAlignment(.leading)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                        
                                                        Text(poll.options[option].count > 999 ? "999+" : "\(poll.options[option].count)")
                                                            .font(.robotoBold(size: 14))
                                                            .foregroundColor(.white)
                                                        
                                                        Image.videoCallPersonPollingIcon
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 18, height: 18)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(16)
                                        
                                        if viewModel.isLoadingVoted[index] {
                                            Color.black.opacity(0.5)
                                            
                                            LottieView(name: "regular-loading", loopMode: .loop)
                                                .scaledToFit()
                                                .frame(height: 30)
                                        }
                                    }
                                    .background(Color(red: 0.21, green: 0.22, blue: 0.22))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                                .padding(.bottom)
                            }
                        }
                    }
                }
                
                if viewModel.meeting.localUser.canDoParticipantHostControls(),
                   !viewModel.isCreatePoll,
                   viewModel.meeting.polls.polls.isEmpty {
                    VStack(spacing: 8) {
                        Text(LocalizableText.videoCallPollingPromotion)
                            .font(.robotoRegular(size: 12))
                            .foregroundStyle(Color.DinotisDefault.black3)
                            .multilineTextAlignment(.center)
                        
                        DinotisPrimaryButton(
                            text: LocalizableText.videoCallCreateNewPollTitle,
                            type: .adaptiveScreen,
                            height: 50,
                            textColor: .white,
                            bgColor: .DinotisDefault.primary,
                            isLoading: .constant(false))
                        {
                            withAnimation(.spring()) {
                                viewModel.isCreatePoll = true
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color(red: 0.15, green: 0.16, blue: 0.16))
        }
    }
    
    struct PollingFormView: View {
        
        @EnvironmentObject var viewModel: GroupVideoCallViewModel
        @FocusState var editorFocused: Bool
        
        var body: some View {
            ZStack {
                VStack(spacing: 12) {
                    Text(LocalizableText.videoCallPollQuestionTitle)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(.white)
                        .padding(10)
                    
                    ZStack(alignment: .topLeading) {
#if os(macOS)
                        TextEditor(text: $viewModel.createPollData.question)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.white)
                            .textFieldStyle(.plain)
                            .frame(height: 75)
                            .textEditorBackground(Color(red: 0.18, green: 0.19, blue: 0.2))
                            .focused($editorFocused)
#else
                        TextEditor(text: $viewModel.createPollData.question)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.white)
                            .textFieldStyle(.plain)
                            .frame(height: 75)
                            .textEditorBackground(Color(red: 0.18, green: 0.19, blue: 0.2))
                            .focused($editorFocused)
#endif
                        
                        if viewModel.createPollData.question.isEmpty && !editorFocused {
                            Text(LocalizableText.videoCallPollQuestionPlaceholder)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.DinotisDefault.black3)
                                .padding(4)
                                .padding(.top, 4)
                                .onTapGesture {
                                    editorFocused = true
                                }
                        }
                    }
                    .tint(.DinotisDefault.primary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(red: 0.18, green: 0.19, blue: 0.2))
                    )
                    
                    ForEach($viewModel.createPollData.options, id:\.id) { $option in
                        HStack(spacing: 8) {
                            TextField(LocalizableText.videoCallMessagePlaceholder, text: $option.text)
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(.white)
                                .textFieldStyle(.plain)
                                .padding(.horizontal, 12)
                                .padding(.vertical)
                                .tint(.DinotisDefault.primary)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color(red: 0.18, green: 0.19, blue: 0.2))
                                )
                            
                            if viewModel.createPollData.options.last?.id == option.id,
                               viewModel.createPollData.options.count > 2 {
                                Button {
                                    withAnimation {
                                        viewModel.createPollData.options.removeLast(1)
                                    }
                                } label: {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(Color(red: 0.18, green: 0.19, blue: 0.2))
                                        
                                        Rectangle()
                                            .foregroundColor(.white)
                                            .frame(height: 3)
                                            .padding(.horizontal, 7)
                                    }
                                    .frame(width: 32, height: 32)
                                    .cornerRadius(4)
                                }
                            }
                        }
                    }
                    
                    Button("+ \(LocalizableText.videoCallPollAddOption)") {
                        withAnimation {
                            viewModel.createPollData.options.append(.init())
                        }
                    }
                    .font(.robotoBold(size: 12))
                    .foregroundColor(.DinotisDefault.lightPrimary)
                    
                    DinotisPrimaryButton(
                        text: LocalizableText.videoCallCreatePollTitle,
                        type: .adaptiveScreen,
                        height: 50,
                        textColor: .white,
                        bgColor: .DinotisDefault.primary,
                        isLoading: .constant(false))
                    {
                        withAnimation(.spring()) {
                            UIApplication.shared.endEditing()
                            viewModel.isLoadingPollCreate = true
                            viewModel.meeting.polls.create(question: viewModel.createPollData.question, options: viewModel.createPollData.options.compactMap({ $0.text }), anonymous: false, hideVotes: false)
                        }
                    }
                    .disabled(viewModel.createPollData.question.isEmpty || viewModel.createPollData.options.contains(where: { $0.text.isEmpty }))
                    
                    DinotisSecondaryButton(
                        text: LocalizableText.videoCallCancelPollTitle,
                        type: .adaptiveScreen,
                        height: 50,
                        textColor: .white,
                        bgColor: .clear,
                        strokeColor: .DinotisDefault.primary)
                    {
                        withAnimation(.spring()) {
                            viewModel.isCreatePoll = false
                            viewModel.createPollData = .init()
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if viewModel.isLoadingPollCreate {
                    Color.black.opacity(0.5)
                    
                    LottieView(name: "regular-loading", loopMode: .loop)
                        .scaledToFit()
                        .frame(height: 45)
                }
            }
            .background(Color(red: 0.21, green: 0.22, blue: 0.22))
            .cornerRadius(12)
            .padding(22)
        }
    }
    
    struct LeaveSessionAlert: View {
        @EnvironmentObject var viewModel: GroupVideoCallViewModel
        
        var body: some View {
            ZStack {
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    if viewModel.isJoined {
                        Text(viewModel.leaveAlertTitle())
                            .font(.robotoMedium(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 4)
                        
                        Text(viewModel.leaveAlertSubtitle())
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(Color(red: 0.63, green: 0.64, blue: 0.66))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 9)
                        
                        if viewModel.meeting.localUser.presetName.contains(PresetConstant.host.value) {
                            VStack(spacing: 8) {
                                DinotisPrimaryButton(
                                    text: LocalizableText.videoCallEndSessionButton,
                                    type: .fixed(220),
                                    height: 51,
                                    textColor: .white,
                                    bgColor: .DinotisDefault.primary
                                ) {
                                    withAnimation(.spring()) {
                                        viewModel.isShowLeavePopUp = false
                                    }
                                    if viewModel.meeting.recording.recordingState == .recording {
                                        viewModel.meeting.recording.stop()
                                    } else {
                                        viewModel.meeting.participants.kickAll()
                                        viewModel.leaveMeeting()
                                    }
                                }
                                .onChange(of: viewModel.meeting.recording.recordingState) { newValue in
                                    if newValue == .stopping {
                                        viewModel.meeting.participants.kickAll()
                                        viewModel.leaveMeeting()
                                    }
                                }
                                
                                DinotisPrimaryButton(
                                    text: LocalizableText.videoCallLeaveRoom,
                                    type: .fixed(220),
                                    height: 51,
                                    textColor: .white,
                                    bgColor: Color(red: 0.32, green: 0.34, blue: 0.36)
                                ) {
                                    viewModel.hideAllAlert()
                                    viewModel.leaveMeeting()
                                }
                                
                                DinotisNudeButton(
                                    text: LocalizableText.cancelLabel,
                                    textColor: .DinotisDefault.primary,
                                    fontSize: 14
                                ) {
                                    withAnimation(.spring()) {
                                        viewModel.isShowLeavePopUp = false
                                    }
                                }
                                .frame(height: 51)
                            }
                            .padding(.top, 8)
                        } else {
                            HStack(spacing: 8) {
                                DinotisPrimaryButton(
                                    text: LocalizableText.cancelLabel,
                                    type: .fixed(113),
                                    height: 51,
                                    textColor: .white,
                                    bgColor: Color(red: 0.32, green: 0.34, blue: 0.36)
                                ) {
                                    withAnimation(.spring()) {
                                        viewModel.isShowLeavePopUp = false
                                    }
                                }
                                
                                DinotisPrimaryButton(
                                    text: LocalizableText.videoCallLeaveRoom,
                                    type: .fixed(113),
                                    height: 51,
                                    textColor: .white,
                                    bgColor: .DinotisDefault.primary
                                ) {
                                    viewModel.hideAllAlert()
                                    viewModel.leaveMeeting()
                                }
                            }
                        }
                    } else {
                        Text(LocalizableText.videoCallLeavePopupTitle)
                            .font(.robotoMedium(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 4)
                        
                        Text(LocalizableText.videoCallLeavePopupSubtitle)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(Color(red: 0.63, green: 0.64, blue: 0.66))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 9)
                        
                        HStack(spacing: 8) {
                            DinotisPrimaryButton(
                                text: LocalizableText.cancelLabel,
                                type: .fixed(113),
                                height: 51,
                                textColor: .white,
                                bgColor: Color(red: 0.32, green: 0.34, blue: 0.36)
                            ) {
                                withAnimation(.spring()) {
                                    viewModel.isShowLeavePopUp = false
                                }
                            }
                            
                            DinotisPrimaryButton(
                                text: LocalizableText.videoCallLeaveRoom,
                                type: .fixed(113),
                                height: 51,
                                textColor: .white,
                                bgColor: .DinotisDefault.primary
                            ) {
                                viewModel.hideAllAlert()
                                viewModel.leaveMeeting()
                            }
                        }
                    }
                }
                .frame(maxWidth: 258)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color(red: 0.18, green: 0.19, blue: 0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .inset(by: 0.5)
                        .stroke(Color(red: 0.32, green: 0.34, blue: 0.36), lineWidth: 1)
                )
                .scaleEffect(viewModel.isShowLeavePopUp ? 1 : 0)
            }
        }
    }
}

struct GroupVideoCallView_Previews: PreviewProvider {
    static var previews: some View {
        GroupVideoCallView(viewModel: GroupVideoCallViewModel(backToHome: {}, backToScheduleDetail: {}, userMeeting: .init(id: nil, title: nil, meetingDescription: nil, price: nil, startAt: nil, endAt: nil, isPrivate: nil, isLiveStreaming: nil, slots: nil, participants: nil, userID: nil, startedAt: nil, endedAt: nil, createdAt: nil, updatedAt: nil, deletedAt: nil, bookings: nil, user: nil, participantDetails: nil, meetingBundleId: nil, meetingRequestId: nil, status: nil, meetingRequest: nil, expiredAt: nil, background: nil, meetingCollaborations: nil, meetingUrls: nil, meetingUploads: nil, roomSid: nil, dyteMeetingId: nil, isInspected: false, reviews: [])))
    }
}
