//
//  TwilioLiveStreamView+Component.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import SwiftUI
import SwiftUINavigation
import Combine
import Introspect
import DinotisData
import DinotisDesignSystem

extension TwilioGroupVideoCallView {
    
    struct VideoSettingView: View {
        @EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
        @ObservedObject var viewModel: TwilioLiveStreamViewModel
        @EnvironmentObject var streamVM: StreamViewModel
        @EnvironmentObject var chatManager: ChatManager
        @EnvironmentObject var streamManager: StreamManager
        
        var body: some View {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(LocaleText.lockMute)
                            .font(.robotoRegular(size: 12))
                            .foregroundColor(.white)
                        
                        Text(LocaleText.muteLockSubtitle)
                            .font(.robotoRegular(size: 10))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Toggle(isOn: $viewModel.isLockAllParticipantAudio) {
                        Text("")
                    }
                    .labelsHidden()
                    .onChange(of: viewModel.isLockAllParticipantAudio) { newValue in
                        viewModel.lockAllParticipantAudio(streamManager: streamManager)
                    }
                }
            }
        }
    }
    
    struct MoreMenuItems: View {
        @EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
        @ObservedObject var viewModel: TwilioLiveStreamViewModel
        @EnvironmentObject var streamVM: StreamViewModel
        @EnvironmentObject var chatManager: ChatManager
        @EnvironmentObject var streamManager: StreamManager
        @EnvironmentObject var participantsViewModel: ParticipantsViewModel
        
        private var columns: [GridItem] {
            [GridItem](
                repeating: GridItem(.flexible(), spacing: 5),
                count: 4
            )
        }
        
        var body: some View {
            LazyVGrid(columns: columns, spacing: 5) {
                
                switch viewModel.state.twilioRole {
                case "host":
                    Button {
                        withAnimation(.spring()) {
                            viewModel.isShowQuestionList.toggle()
                            viewModel.showingMoreMenu = false
                        }
                        
                    } label: {
                        VStack {
                            ZStack(alignment: .topTrailing) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.dinotisStrokeSecondary)
                                        .frame(width: 45, height: 45)
                                    
                                    Image(systemName: "bubble.left.and.bubble.right")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 20)
                                        .foregroundColor(.white)
                                }
                                
                                if streamVM.hasNewQuestion {
                                    Circle()
                                        .foregroundColor(.red)
                                        .frame(width: 12, height: 12)
                                }
                            }
                            
                            Text(LocaleText.qna)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    //FIXME: - Button mute all only
                    Button {
                        withAnimation(.spring()) {
                            viewModel.muteOnlyAllParticipant(streamManager: streamManager)
                        }
                    } label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .stroke(Color.dinotisStrokeSecondary)
                                    .frame(width: 45, height: 45)
                                
                                Image(systemName: "shareplay.slash")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                    .foregroundColor(.white)
                            }
                            
                            Text(LocaleText.muteAllParticipantText)
                                .font(.robotoMedium(size: 10))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    //FIXME: - Button setting with mute all lock
                    Button {
                        withAnimation(.spring()) {
                            viewModel.showingMoreMenu = false
                            viewModel.showSetting.toggle()
                        }
                    } label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .stroke(Color.dinotisStrokeSecondary)
                                    .frame(width: 45, height: 45)
                                
                                Image(systemName: "gearshape")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                    .foregroundColor(.white)
                            }
                            
                            Text(LocaleText.settingText)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Button {
                        withAnimation(.spring()) {
                            viewModel.showingMoreMenu = false
                            streamVM.alertIdentifier = .removeAllParticipant
                        }
                    } label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .stroke(Color.dinotisStrokeSecondary)
                                    .frame(width: 45, height: 45)
                                
                                Image(systemName: "person.crop.circle.badge.minus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                    .foregroundColor(.white)
                            }
                            
                            Text(LocaleText.removeAllParticipants)
                                .font(.robotoMedium(size: 10))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .onChange(of: participantsViewModel.speakers.count) { _ in
                        if participantsViewModel.speakers.count + participantsViewModel.viewerCount >= 50 && participantsViewModel.speakers.count >= 2 {
                            withAnimation(.spring()) {
                                viewModel.isButtonActive = true
                            }
                        } else if participantsViewModel.speakers.count + participantsViewModel.viewerCount < 50  {
                            withAnimation(.spring()) {
                                viewModel.isButtonActive = false
                            }
                        }
                    }
                    .disabled(!viewModel.isButtonActive)
                    
                case "speaker":
                    Button {
                        withAnimation(.spring()) {
                            viewModel.isShowQuestionBox.toggle()
                            viewModel.showingMoreMenu = false
                        }
                    } label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .stroke(Color.dinotisStrokeSecondary)
                                    .frame(width: 45, height: 45)
                                
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .scaledToFit()
                                    .frame(height: 25)
                                    .foregroundColor(.white)
                            }
                            
                            Text(LocaleText.qna)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                case "viewer":
                    Button {
                        withAnimation(.spring()) {
                            viewModel.isShowQuestionBox.toggle()
                            viewModel.showingMoreMenu = false
                        }
                    } label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .stroke(Color.dinotisStrokeSecondary)
                                    .frame(width: 45, height: 45)
                                
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .scaledToFit()
                                    .frame(height: 25)
                                    .foregroundColor(.white)
                            }
                            
                            Text(LocaleText.groupCallQuestionBox)
                                .font(.robotoMedium(size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                default:
                    EmptyView()
                }
                
                Button {
                    withAnimation(.spring()) {
                        viewModel.isShowingChat.toggle()
                        viewModel.showingMoreMenu = false
                    }
                } label: {
                    
                    VStack {
                        ZStack(alignment: .topTrailing) {
                            ZStack {
                                Circle()
                                    .stroke(Color.dinotisStrokeSecondary)
                                    .frame(width: 45, height: 45)
                                
                                Image.Dinotis.liveChatGroupIcon
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 25)
                                    .foregroundColor(.white)
                            }
                            
                            if chatManager.hasUnreadMessage {
                                Circle()
                                    .foregroundColor(.red)
                                    .frame(width: 12, height: 12)
                            }
                        }
                        
                        Text(LocaleText.liveScreenLiveChat)
                            .font(.robotoMedium(size: 12))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                }
                
            }
        }
    }
    
    struct BottomToolbar: View {
        
        @ObservedObject var speakerSettingsManager: SpeakerSettingsManager
        @ObservedObject var viewModel: TwilioLiveStreamViewModel
        @EnvironmentObject var streamVM: StreamViewModel
        @EnvironmentObject var chatManager: ChatManager
        @EnvironmentObject var participantsViewModel: ParticipantsViewModel
        @EnvironmentObject var streamManager: StreamManager
        @EnvironmentObject var speakerGridVM: SpeakerGridViewModel
        
        let closeLive: (() -> Void)
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            HStack {
                Spacer()
                
                switch viewModel.state.twilioRole {
                case "host":
                    Button {
                        withAnimation(.spring()) {
                            speakerSettingsManager.isMicOn.toggle()
                        }
                    } label: {
                        (!speakerSettingsManager.isMicOn ? Image.videoCallMicrophoneActiveIcon : Image.videoCallMicrophoneInactiveIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                    }
                    
                    
                    Button {
                        withAnimation(.spring()) {
                            speakerSettingsManager.isCameraOn.toggle()
                        }
                    } label: {
                        (!speakerSettingsManager.isCameraOn ? Image.videoCallVideoCameraActiveIcon : Image.videoCallVideoCameraInactiveIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.isSwitched.toggle()
                        }
                    }) {
                        Image.videoCallSwitchCameraActiveIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                    }
                    
                case "speaker":
                    Button {
                        withAnimation(.spring()) {
                            speakerSettingsManager.isMicOn.toggle()
                        }
                    } label: {
                        (!speakerSettingsManager.isMicOn ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                    }
                    .disabled(streamVM.isAudioLocked)
                    .onChange(of: streamVM.isAudioLocked) { newValue in
                        if newValue {
                            speakerSettingsManager.isMicOn = false
                        }
                    }
                    
                    Button {
                        withAnimation(.spring()) {
                            speakerSettingsManager.isCameraOn.toggle()
                        }
                    } label: {
                        (!speakerSettingsManager.isCameraOn ? Image.videoCallVideoOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                    }
                    
                    //                    Button(action: {
                    //                        withAnimation(.spring()) {
                    //                            viewModel.isSwitched.toggle()
                    //                        }
                    //                    }) {
                    //                        Image.videoCallSwitchCameraActiveIcon
                    //                            .resizable()
                    //                            .scaledToFit()
                    //                            .frame(height: 45)
                    //                    }
                    
                    Button {
                        viewModel.isShowingChat.toggle()
                    } label: {
                        Image.videoCallChatIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                            .foregroundColor(.white)
                    }
                    
                case "viewer":
                    Button {
                        withAnimation(.spring()) {
                            streamVM.isHandRaised.toggle()
                        }
                    } label: {
                        (streamVM.isHandRaised ? Image.videoCallRaiseHandActive : Image.videoCallRaiseHandInactive)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                    }
                    
                    Button {
                        viewModel.isShowingChat.toggle()
                    } label: {
                        Image.videoCallChatIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                            .foregroundColor(.white)
                    }
                    
                    Button {
                        
                    } label: {
                        Image.videoCallQuestionIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                            .foregroundColor(.white)
                    }
                    
                default:
                    EmptyView()
                }
                //
                //                                Button {
                //                                    withAnimation(.spring()) {
                //                                        viewModel.isShowingParticipants.toggle()
                //                                        participantsViewModel.haveNewRaisedHand = false
                //                                    }
                //                                } label: {
                //                                    ZStack(alignment: .topTrailing) {
                //                                        ZStack {
                //                                            Image.videoCallParticipantInactiveIcon
                //                                                .resizable()
                //                                                .scaledToFit()
                //                                                .frame(height: 45)
                //                                        }
                //
                //                                        if participantsViewModel.haveNewRaisedHand && StateObservable.shared.twilioRole == "host" {
                //                                            Circle()
                //                                                .foregroundColor(.red)
                //                                                .frame(width: 12, height: 12)
                //                                        }
                //                                    }
                //                                }
                //                                .onChange(of: viewModel.isSwitched) { newValue in
                //                                    streamManager.roomManager?.localParticipant.position = newValue ? .front : .back
                //                                }
                
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
                        
                        if (streamVM.hasNewQuestion || chatManager.hasUnreadMessage) && StateObservable.shared.twilioRole == "host" {
                            Circle()
                                .foregroundColor(.red)
                                .frame(width: 12, height: 12)
                        }
                        
                    }
                }
                
                if streamManager.state != .connecting {
                    Button {
                        withAnimation(.spring()) {
                            speakerGridVM.isEnd = true
                            viewModel.showingCloseAlert()
                        }
                    } label: {
                        Image.Dinotis.closeGroupCallIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                    }
                }
                
                Spacer()
            }
            .buttonStyle(.plain)
        }
    }
    
    struct AboutCallBottomSheet: View {
        @ObservedObject var viewModel: ParticipantsViewModel
        @Environment(\.presentationMode) var presentationMode
        @ObservedObject var twilioLiveVM: TwilioLiveStreamViewModel
        @EnvironmentObject var streamManager: StreamManager
        @Namespace var namespace
        
        var body: some View {
            VStack {
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
                
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            viewModel.tabSelection = 0
                        }
                    } label: {
                        VStack(spacing: 16) {
                            Text(LocalizableText.labelChat)
                                .font(.robotoBold(size: 16))
                                .foregroundColor(viewModel.tabSelection == 0 ? .blue : .white)
                            
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.blue)
                                .isHidden(viewModel.tabSelection != 0)
                                .matchedGeometryEffect(id: "bottom", in: namespace)
                        }
                        .animation(.spring(), value: viewModel.tabSelection)
                    }
                    
                    Spacer()
                    Button {
                        withAnimation {
                            viewModel.tabSelection = 1
                        }
                    } label: {
                        VStack(spacing: 16) {
                            Text(LocalizableText.participant)
                                .font(.robotoBold(size: 16))
                                .foregroundColor(viewModel.tabSelection == 1 ? .blue : .white)
                            
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.blue)
                                .isHidden(viewModel.tabSelection != 1)
                                .matchedGeometryEffect(id: "bottom", in: namespace)
                        }
                        .animation(.spring(), value: viewModel.tabSelection)
                    }
                    
                    Spacer()
                    Button {
                        withAnimation {
                            viewModel.tabSelection = 2
                        }
                    } label: {
                        VStack(spacing: 16) {
                            Text(LocalizableText.labelPolls)
                                .font(.robotoBold(size: 16))
                                .foregroundColor(viewModel.tabSelection == 2 ? .blue : .white)
                            
                            Rectangle()
                                .frame(height: 2)
                                .foregroundColor(.blue)
                                .isHidden(viewModel.tabSelection != 2)
                                .matchedGeometryEffect(id: "bottom", in: namespace)
                        }
                        .animation(.spring(), value: viewModel.tabSelection)
                    }
                    
                    Spacer()
                }
                
                Group {
                    switch viewModel.tabSelection {
                    case 0:
                        ChatView(viewModel: twilioLiveVM)
                    case 1:
                        ParticipantTabView(twilioLiveVM: twilioLiveVM)
                    case 2:
                        PollingView()
                    default:
                        EmptyView()
                    }
                }
                .animation(.easeInOut, value: viewModel.tabSelection)
            }
        }
    }
    
    
    struct ParticipantTabView: View {
        
        @EnvironmentObject var viewModel: ParticipantsViewModel
        @ObservedObject var twilioLiveVM: TwilioLiveStreamViewModel
        @EnvironmentObject var streamManager: StreamManager
        
        var body: some View {
            VStack {
                HStack(spacing: 12) {
                    Image.bottomNavigationSearchWhiteIcon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    TextField("Search...", text: $viewModel.searchText)
                        .font(.robotoRegular(size: 16))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.DinotisDefault.black2)
                
                List {
                    if twilioLiveVM.state.twilioRole == "host" {
                        if !viewModel.joiningParticipant.isEmpty {
                            Section(
                                header: HStack {
                                    Text("\(LocalizableText.titleWaitingRoom) (\(viewModel.joiningParticipant.count))")
                                        .font(.robotoBold(size: 16))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button {
                                        
                                    } label: {
                                        Text(LocalizableText.acceptAllLabel)
                                            .font(.robotoBold(size: 12))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .frame(width: 103, alignment: .center)
                                            .background(Color.blue)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            ) {
                                ForEach(viewModel.joiningParticipant, id: \.id) { participant in
                                    HStack(spacing: 16) {
                                        Circle()
                                            .foregroundColor(.blue)
                                            .frame(width: 42, height: 42)
                                        
                                        Text(participant.name)
                                            .font(.robotoBold(size: 16))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Button {
                                            
                                        }label: {
                                            Text(LocalizableText.acceptToJoinLabel)
                                                .font(.robotoBold(size: 12))
                                                .foregroundColor(.blue)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 8)
                                                .frame(width: 103, alignment: .center)
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .inset(by: 0.5)
                                                        .stroke(Color.blue, lineWidth: 1)
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
                    
                    if !viewModel.speakerParticipant.isEmpty {
                        Section(
                            header: HStack {
                                Text("\(LocalizableText.speakerTitle) (\(viewModel.speakerParticipant.count))")
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                        ) {
                            ForEach(viewModel.speakerParticipant, id: \.id) { participant in
                                HStack(spacing: 16) {
                                    Circle()
                                        .foregroundColor(.blue)
                                        .frame(width: 42, height: 42)
                                    
                                    Text(participant.name)
                                        .font(.robotoBold(size: 16))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        (participant.isMicOn ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24)
                                        
                                        (participant.isVideoOn ? Image.videoCallVideoOnStrokeIcon : Image.videoCallVideoOffStrokeIcon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24)
                                    }
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listRowSeparator(.hidden)
                        
                        if !viewModel.viewerSpeaker.isEmpty {
                            Section(
                                header: HStack {
                                    Text("\(LocalizableText.viewerTitle) (\(viewModel.viewerSpeaker.count))")
                                        .font(.robotoBold(size: 16))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                            ) {
                                ForEach(viewModel.viewerSpeaker, id: \.id) { participant in
                                    HStack(spacing: 16) {
                                        Circle()
                                            .foregroundColor(.blue)
                                            .frame(width: 42, height: 42)
                                        
                                        Text(participant.name)
                                            .font(.robotoBold(size: 16))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 8) {
                                            (participant.isMicOn ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24)
                                            
                                            (participant.isVideoOn ? Image.videoCallVideoOnStrokeIcon : Image.videoCallVideoOffStrokeIcon)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24)
                                        }
                                    }
                                    .listRowSeparator(.hidden)
                                }
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .animation(.spring(), value: viewModel.searchedParticipant)
            }
        }
    }
    
    struct QuestionList: View {
        
        @ObservedObject var viewModel: TwilioLiveStreamViewModel
        @EnvironmentObject var participantVM: ParticipantsViewModel
        @EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
        @EnvironmentObject var streamVM: StreamViewModel
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            NavigationView {
                VStack {
                    
                    Picker(selection: $viewModel.QnASegment) {
                        Text("Unanswered").tag(0)
                        
                        Text("Answered").tag(1)
                    } label: {
                        Text("")
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    DinotisList { view in
                        view.separatorStyle = .none
                    } content: {
                        VStack {
                            ForEach(viewModel.qnaFiltered(), id:\.id) { item in
                                Button {
                                    viewModel.putQuestion(questionId: item.id.orZero(), item: item, streamVM: streamVM)
                                } label: {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            if item.isAnswered ?? false {
                                                Image(systemName: "checkmark.square")
                                                    .foregroundColor(.DinotisDefault.primary)
                                            } else {
                                                Image(systemName: "square")
                                                    .foregroundColor(.DinotisDefault.primary)
                                            }
                                            
                                            Text((item.user?.name).orEmpty())
                                                .font(.robotoBold(size: 14))
                                                .foregroundColor(.dinotisGray)
                                            
                                            Spacer()
                                            
                                            Text(DateUtils.dateFormatter(item.createdAt.orCurrentDate(), forFormat: .HHmm))
                                                .font(.robotoRegular(size: 12))
                                                .foregroundColor(.dinotisGray)
                                        }
                                        
                                        Divider()
                                        
                                        Text(item.question.orEmpty())
                                            .font(.robotoRegular(size: 14))
                                            .foregroundColor(.dinotisGray)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding()
                                    .background(Color.secondaryViolet)
                                    .cornerRadius(12)
                                }
                                .disabled(viewModel.QnASegment == 1)
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                }
                .padding(.vertical)
                .onAppear {
                    viewModel.getQuestion(meetingId: viewModel.meeting.id.orEmpty())
                    
                    streamVM.hasNewQuestion = false
                }
                .onDisappear(perform: {
                    streamVM.hasNewQuestion = false
                })
                .navigationTitle("Q&A")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(LocaleText.back) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    struct ChatView: View {
        @Environment(\.presentationMode) var presentationMode
        @EnvironmentObject var chatManager: ChatManager
        @State private var isFirstLoadComplete = false
        @ObservedObject var viewModel: TwilioLiveStreamViewModel
        @State var shouldShowImagePicker = false
        @State var image: UIImage?
        
        var body: some View {
            NavigationView {
                VStack {
                    HStack {
                        Image(systemName: "person.3")
                            .resizable()
                            .frame(width: 20, height: 12)
                            .foregroundColor(.white)
                        
                        Text("To Everyone")
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                        
                        Spacer()
                        Button {
                            
                        } label: {
                            Image(systemName: "chevron.down")
                                .resizable()
                                .frame(width: 12, height: 7)
                                .foregroundColor(.white)
                        }
                        
                    }
                    Divider()
                        .foregroundColor(.white)
                        .padding()
                    ScrollViewReader { scrollView in
                        VStack(spacing: 0) {
                            ScrollView {
                                LazyVStack {
                                    ForEach(chatManager.messages) { message in
                                        VStack(spacing: 9) {
                                            ChatHeaderView(
                                                author: message.author,
                                                isAuthorYou: message.author == viewModel.state.twilioUserIdentity,
                                                date: message.date
                                            )
                                            ChatBubbleView(
                                                messageBody: message.body,
                                                isAuthorYou: message.author == viewModel.state.twilioUserIdentity
                                            )
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 7)
                                        .id(message.id)
                                    }
                                    
                                }
                                
                            }
                            .onChange(of: chatManager.messages.count) { count in
                                withAnimation {
                                    scrollView.scrollTo((chatManager.messages.last?.id).orEmpty(), anchor: .bottom)
                                }
                                
                                chatManager.hasUnreadMessage = false
                            }
                            .onChange(of: isFirstLoadComplete) { newValue in
                                scrollView.scrollTo((chatManager.messages.last?.id).orEmpty())
                            }
                            .onAppear {
                                isFirstLoadComplete.toggle()
                                UIScrollView.appearance().keyboardDismissMode = .interactive
                                chatManager.hasUnreadMessage = false
                                chatManager.getMessages()
                            }
                            .onDisappear {
                                chatManager.messages = []
                            }
                            
                            HStack {
                                
                                HStack {
                                    MultilineTextField(LocaleText.liveScreenChatboxPlaceholder, text: $viewModel.messageText)
                                    Button(action: {
                                        
                                    }, label: {
                                        Image(systemName: "link")
                                            .foregroundColor(.white)
                                    })
                                    Button(action: {
                                        shouldShowImagePicker.toggle()
                                    }, label: {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .foregroundColor(.white)
                                    })
                                    .padding(5)
                                    
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(UIApplication.shared.windows.first?.overrideUserInterfaceStyle == .dark ? Color.white : Color(.systemGray3), lineWidth: 1)
                                        .frame(height: 37)
                                )
                                
                                Button {
                                    chatManager.sendMessage(viewModel.messageText)
                                    viewModel.messageText = ""
                                } label: {
                                    Image.Dinotis.sendMessageIcon
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(
                                            viewModel.messageText.isEmpty || !viewModel.messageText.isStringContainWhitespaceAndText() ?
                                            Color(.white) : .sendButtonDisabledColor()
                                        )
                                    
                                }
                                
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .disabled(viewModel.messageText.isEmpty || !viewModel.messageText.isStringContainWhitespaceAndText())
                                
                            }
                            .padding()
                        }
                        
                    }
                }
                .navigationTitle(LocaleText.liveScreenLiveChat)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(LocaleText.back) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    struct ChatHeaderView: View {
        let author: String
        let isAuthorYou: Bool
        let date: Date
        
        var body: some View {
            HStack {
                if isAuthorYou {
                    
                    Text(date, style: .time)
                    
                    Spacer()
                    
                    Text("\(author)\(isAuthorYou ? " (\(LocaleText.you))" : "")")
                        .lineLimit(1)
                    
                } else {
                    Text("\(author)\(isAuthorYou ? " (\(LocaleText.you))" : "")")
                        .lineLimit(1)
                    Spacer()
                    Text(date, style: .time)
                }
            }
            .foregroundColor(.white)
            .font(.robotoRegular(size: 12))
        }
    }
    
    struct ChatBubbleView: View {
        let messageBody: String
        let isAuthorYou: Bool
        
        var body: some View {
            HStack {
                
                if isAuthorYou {
                    Spacer()
                }
                
                Text(messageBody)
                    .font(.robotoRegular(size: 14))
                    .foregroundColor(.dinotisGray)
                    .padding(10)
                    .background(isAuthorYou ? Color.secondaryViolet : Color.dinotisStrokeSecondary)
                    .cornerRadius(20)
                    .multilineTextAlignment(isAuthorYou ? .trailing : .leading)
                
                if !isAuthorYou {
                    Spacer()
                }
            }
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
                                Text("Poll Question by Host")
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
                                        Text("Poll Question")
                                            .foregroundColor(.white)
                                            .padding(.top,10)
                                        
                                        if #available(iOS 16.0, *) {
                                            TextField("", text: $fieldPoll, axis: .vertical)
                                                .placeholder(when: fieldPoll.isEmpty, placeholder: {
                                                    Text("What is your poll for?").foregroundColor(.white)
                                                })
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
                                                    .foregroundColor(.blue)
                                                Text("Add an option")
                                                    .foregroundColor(.blue)
                                                
                                            }
                                            
                                        }
                                        
                                        
                                        VStack {
                                            Toggle(isOn: $isCheckedOne) {
                                                Text("Anonymous")
                                            }
                                            .toggleStyle(CheckboxStyle())
                                            Toggle(isOn: $isCheckedTwo) {
                                                Text("Hide result before voting")
                                            }
                                            .toggleStyle(CheckboxStyle())
                                            
                                            
                                            
                                        }.padding(.trailing, 210)
                                        
                                        
                                        Button {
                                            isPollCreated.toggle()
                                        } label: {
                                            Text("Create Poll")
                                                .foregroundColor(Color.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.blue).cornerRadius(10)
                                                .border(Color.blue).cornerRadius(10)
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
                                Text("Engage Your Participant With Poll!")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                
                                Button {
                                    isPollCard.toggle()
                                    
                                } label: {
                                    Text(isPollCard ? "Cancel Poll" : "Create New Poll")
                                        .foregroundColor(isPollCard ? Color.blue : Color.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(!isPollCard ? Color.blue : Color.clear).cornerRadius(10)
                                        .border(Color.blue).cornerRadius(10)
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

struct DetailMeetingView: View {
    var meeting: UserMeetingData?
    @ObservedObject var viewModel: TwilioLiveStreamViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text((meeting?.title).orEmpty())
                .font(.robotoBold(size: 14))
                .foregroundColor(.black)
            
            Text((meeting?.meetingDescription).orEmpty())
                .font(.robotoRegular(size: 12))
                .foregroundColor(.black)
                .padding(.bottom, 10)
            
            HStack(spacing: 10) {
                Image.Dinotis.calendarIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18)
                
                if let dateStart = meeting?.startAt {
                    Text(DateUtils.dateFormatter(dateStart, forFormat: .EEEEddMMMMyyyy))
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.black)
                }
            }
            
            HStack(spacing: 10) {
                Image.Dinotis.clockIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18)
                
                if let timeStart = meeting?.startAt,
                   let timeEnd = meeting?.endAt {
                    Text("\(DateUtils.dateFormatter(timeStart, forFormat: .HHmm)) - \(DateUtils.dateFormatter(timeEnd, forFormat: .HHmm))")
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 10) {
                    Image.Dinotis.peopleCircleIcon
                        .resizable()
                        .scaledToFit()
                        .frame(height: 18)
                    
                    Text(viewModel.totalParticipant(meeting: meeting))
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.black)
                    
                    Text(viewModel.contentLabel(meeting: meeting))
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.black)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .background(Color.secondaryViolet)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.DinotisDefault.primary, lineWidth: 1.0)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.white)
        )
        .padding(EdgeInsets(top: 25, leading: 30, bottom: 25, trailing: 30))
    }
}

extension String {
    func isStringContainWhitespaceAndText() -> Bool {
        guard let array = self.compactMap({ $0 }) as? [Character] else { return false }
        
        guard let boolArray = array.compactMap({ !$0.isWhitespace }) as? [Bool] else { return false }
        
        return boolArray.contains(true)
    }
}

extension Color {
    static func sendButtonDisabledColor() -> Color {
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle == .dark ? .white : .DinotisDefault.primary
    }
}


extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}
