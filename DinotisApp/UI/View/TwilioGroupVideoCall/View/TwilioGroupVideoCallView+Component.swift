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
        @Environment(\.dismiss) var dismiss
        
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
                        (!speakerSettingsManager.isMicOn ? Image.videoCallMicrophoneActiveIcon : Image.videoCallMicrophoneInactiveIcon)
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
                    
                case "viewer":
                    Button {
                        withAnimation(.spring()) {
                            streamVM.isHandRaised.toggle()
                        }
                    } label: {
                        (streamVM.isHandRaised ? Image.videoCallRaiseHandActiveIcon : Image.videoCallRaiseHandInactiveIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                    }
                    
                    
                default:
                    EmptyView()
                }
                
                Button {
                    withAnimation(.spring()) {
                        viewModel.isShowingParticipants.toggle()
                        participantsViewModel.haveNewRaisedHand = false
                    }
                } label: {
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            Image.videoCallParticipantInactiveIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: 45)
                        }
                        
                        if participantsViewModel.haveNewRaisedHand && StateObservable.shared.twilioRole == "host" {
                            Circle()
                                .foregroundColor(.red)
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                .onChange(of: viewModel.isSwitched) { newValue in
                    streamManager.roomManager?.localParticipant.position = newValue ? .front : .back
                }
                
                Button {
                    withAnimation(.spring()) {
                        viewModel.showingMoreMenu.toggle()
                    }
                } label: {
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            Image.videoCallMenuInactiveIcon
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
    
    struct ParticipantView: View {
        
        @EnvironmentObject var viewModel: ParticipantsViewModel
        @ObservedObject var twilioLiveVM: TwilioLiveStreamViewModel
        @EnvironmentObject var streamManager: StreamManager
        @EnvironmentObject var participantsViewModel: ParticipantsViewModel
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            NavigationView {
                List {
                    Section(header: Text("Speakers (\(viewModel.speakers.count))")
                        .font(.robotoBold(size: 16)).foregroundColor(.secondaryViolet)) {
                        ForEach(viewModel.speakers.unique(), id: \.identity) { speaker in
                            HStack {
                                Text("\(speaker.identity.orEmpty()) \((speaker.coHost ?? false) ? "(Co-Host)" : "")\((speaker.host ?? false) ? "(Host)" : "")")
                                    .font(.robotoRegular(size: 14))
                                Spacer()
                            }
                        }
                    }
                    
                    if twilioLiveVM.state.twilioRole == "speaker" || twilioLiveVM.state.twilioRole == "host" {
                        Section(header: Text("Viewers (\(viewModel.updateViewerCount()))")
                            .font(.robotoBold(size: 14)).foregroundColor(.secondaryViolet)) {
                            
                            ForEach(viewModel.viewersWithoutRaisedHand.unique(), id: \.identity) { viewer in
                                HStack {
                                    if viewModel.viewersWithRaisedHand.unique().contains(where: { item in
                                        item.identity == viewer.identity
                                    }) {
                                        HStack {
                                            Text("\(viewer.identity.orEmpty()) 👋")
                                                .font(.robotoRegular(size: 14))
                                                .alert(isPresented: $viewModel.showSpeakerInviteSent) {
                                                    Alert(
                                                        title: Text(LocaleText.invitationSent),
                                                        message: Text("\(LocaleText.speakerInviteMessage1) \(viewer.identity.orEmpty()) \(LocaleText.speakerInviteMessage2)"),
                                                        dismissButton: .default(Text(LocaleText.gotIt))
                                                    )
                                                }
                                            
                                            Spacer()
                                            
                                            if streamManager.stateObservable.twilioRole == "host" {
                                                Button(LocaleText.inviteToSpeak) {
                                                    viewModel.sendSpeakerInvite(meetingId: twilioLiveVM.meeting.id.orEmpty(), userIdentity: viewer.identity.orEmpty())
                                                }
                                                .font(.robotoMedium(size: 14))
                                                .alert(isPresented: $viewModel.showError) {
                                                    
                                                    Alert(
                                                        title: Text(LocaleText.attention),
                                                        message: Text(viewModel.error?.localizedDescription ?? ""),
                                                        dismissButton: .default(Text(LocaleText.okText))
                                                    )
                                                }
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    } else {
                                        Text(viewer.identity.orEmpty())
                                            .font(.robotoRegular(size: 14))
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .animation(.default)
                .navigationTitle("\(LocaleText.generalParticipant) (\(viewModel.speakers.unique().count))")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(LocaleText.okText) {
                            dismiss()
                            participantsViewModel.haveNewRaisedHand = false
                        }
                    }
                }
            }
        }
    }
    
    struct QuestionList: View {
        
        @ObservedObject var viewModel: TwilioLiveStreamViewModel
        @EnvironmentObject var participantVM: ParticipantsViewModel
        @EnvironmentObject var speakerSettingsManager: SpeakerSettingsManager
        @EnvironmentObject var streamVM: StreamViewModel
        @Environment(\.dismiss) var dismiss
        
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
                                        Task {
                                            await viewModel.putQuestion(item: item)
                                        }
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
                    Task {
                       await viewModel.getQuestion()
                    }
                    
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
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    struct ChatView: View {
        @Environment(\.dismiss) var dismiss
        @EnvironmentObject var chatManager: ChatManager
        @State private var isFirstLoadComplete = false
        @ObservedObject var viewModel: TwilioLiveStreamViewModel
        
        var body: some View {
            NavigationView {
                VStack {
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
                            MultilineTextField(LocaleText.liveScreenChatboxPlaceholder, text: $viewModel.messageText)
                                .padding(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(UIApplication.shared.windows.first?.overrideUserInterfaceStyle == .dark ? Color.white : Color(.systemGray3), lineWidth: 1)
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
                                        Color(.systemGray3) : .sendButtonDisabledColor()
                                    )
                                    .frame(height: 28)
                            }
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
                            dismiss()
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
