//
//  GroupVideoCallView.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/23.
//

import DinotisDesignSystem
import DyteiOSCore
import SwiftUI

struct GroupVideoCallView: View {
    
    @ObservedObject var viewModel: GroupVideoCallViewModel
    
    var body: some View {
        
        GeometryReader { geo in
            VStack {
                Spacer()
                    .frame(height: 50)
                    .isHidden(!viewModel.isShowingToolbar || UIDevice.current.orientation.isLandscape, remove: !viewModel.isShowingToolbar || UIDevice.current.orientation.isLandscape)
                
                TabView(selection: $viewModel.index) {
                    VStack {
                        LocalUserVideoContainerView(viewModel: viewModel)
                            .padding(.horizontal)
                            .padding(.bottom)
                        
                        Spacer()
                            .frame(height: 116)
                            .isHidden(!viewModel.isShowingToolbar || UIDevice.current.orientation.isLandscape, remove: !viewModel.isShowingToolbar || UIDevice.current.orientation.isLandscape)
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
                    .tag(0)
                    
                    VStack {
                        ScrollView {
                            if viewModel.isJoined {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 176))]) {
                                    ForEach($viewModel.participants, id: \.id) { item in
                                        RemoteUserJoinedVideoContainerView(viewModel: viewModel, participant: item)
                                    }
                                }
                            }
                            
                        }
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: viewModel.index, perform: { newValue in
                    if viewModel.isJoined {
                        if newValue == 0 {
                            viewModel.localUser = viewModel.meeting.localUser
                        } else {
                            viewModel.localUser = nil
                            viewModel.participants = viewModel.meeting.participants.active
                        }
                    }
                })
                .onTapGesture {
                    withAnimation {
                        viewModel.isShowingToolbar.toggle()
                    }
                }
            }
        }
        .background(
            Image.videoCallBackgroundPattern
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        )
        .overlay {
            VStack {
                HStack {
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
                        if viewModel.meeting.localUser.permissions.media.canPublishVideo {
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
                
                HStack(spacing: 5) {
                    ForEach(0...1, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 30)
                            .foregroundColor(viewModel.index == index ? .blue : .gray)
                            .frame(width: 16, height: 8)
                    }
                }
                .padding(.bottom, viewModel.isShowingToolbar ? 0 : 24)
                
                BottomToolBar(viewModel: viewModel)
                    .isHidden(!viewModel.isShowingToolbar, remove: !viewModel.isShowingToolbar)
            }
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.onAppear()
            AppDelegate.orientationLock = .all
            
            UIApplication.shared.isIdleTimerDisabled = true
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
            
            FontInjector.registerFonts()
        }
        .onDisappear {
            viewModel.onDisappear()
            AppDelegate.orientationLock = .portrait
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        }
        .onChange(of: viewModel.isInit) { newValue in
            if newValue {
                viewModel.joinMeeting()
            }
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
    }
}

fileprivate extension GroupVideoCallView {
    
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
                        Button {
                            viewModel.showingMoreMenu = false
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                self.viewModel.isShowingQnA.toggle()
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 11) {
                                Image.videoCallQuestionIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 23)
                                
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
                        
                        Button {
                            viewModel.showingMoreMenu = false
                            viewModel.tabSelection = 1
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                                self.viewModel.isShowAboutCallBottomSheet = true
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 11) {
                                Image.videoCallNewParticipantIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 23)
                                
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
                        
                        if viewModel.localUser?.canDoParticipantHostControls() ?? false {
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
                        }
                        
                        Button {
                            
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
                        viewModel.toggleMicrophone()
                    }
                } label: {
                    (viewModel.isAudioOn ? Image.videoCallMicOnStrokeIcon : Image.videoCallMicOffStrokeIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                }
                .disabled(false) // Add logic when audio is locked
                
                Button {
                    withAnimation(.spring()) {
                        viewModel.toggleCamera()
                    }
                } label: {
                    (viewModel.isCameraOn ? Image.videoCallVideoOnStrokeIcon : Image.videoCallVideoOffStrokeIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                }
                
                Button {
                    viewModel.tabSelection = 0
                    viewModel.isShowAboutCallBottomSheet.toggle()
                } label: {
                    Image.videoCallChatIcon
                        .resizable()
                        .scaledToFit()
                        .frame(height: 45)
                        .foregroundColor(.white)
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
                    }
                }
                
                Button {
                    withAnimation(.spring()) {
//                        viewModel.leaveMeeting()
//                        MARK: For Testing Only. Remove this when the feature is ready
                        viewModel.isShowQuestionBox.toggle()
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
                            .foregroundColor(.DinotisDefault.black1)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay(
                                ImageLoader(url: (viewModel.localUser?.picture).orEmpty(), width: .infinity, height: .infinity)
                                    .frame(width: 136, height: 136)
                                    .clipShape(Circle())
                            )
                    }
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .foregroundColor(.DinotisDefault.black1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                if viewModel.localUser != nil {
                    HStack(spacing: 0) {
                        if !(viewModel.localUser?.fetchAudioEnabled() ?? false) {
                            Image.videoCallMicOffStrokeIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15)
                        }
                        
                        Text(" \(viewModel.localUser?.name ?? "") \(viewModel.localUser?.canDoParticipantHostControls() ?? false ? "(host)" : "")")
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
    }
    
    struct RemoteUserJoinedVideoContainerView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Binding var participant: DyteJoinedMeetingParticipant
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                if viewModel.index == 0 && (viewModel.localUser?.id).orEmpty() == participant.id {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.DinotisDefault.black1)
                        .frame(width: 176, height: 246)
                } else {
                    if participant.fetchVideoEnabled() {
                        if let video = participant.getVideoView() {
                            UIVideoView(videoView: video, width: 176, height: 246)
                                .frame(width: 176, height: 246)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.DinotisDefault.black1)
                            .frame(width: 176, height: 246)
                            .overlay(
                                ImageLoader(url: participant.picture.orEmpty(), width: 136, height: 136)
                                    .frame(width: 136, height: 136)
                                    .clipShape(Circle())
                            )
                    }
                }
                
                HStack(spacing: 0) {
                    if !participant.fetchAudioEnabled() {
                        Image.videoCallMicOffStrokeIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12)
                    }
                    
                    Text(" \(participant.name) \(participant.isHost ? "(host)" : "")")
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
                                    .font(.robotoBold(size: 16))
                                    .foregroundColor(viewModel.tabSelection == item.id ? .blue : .white)
                                
                                if viewModel.tabSelection == item.id {
                                    RoundedRectangle(cornerRadius: 8)
                                        .frame(width: 24, height: 2)
                                        .foregroundColor(.blue)
                                        .matchedGeometryEffect(id: "bottom", in: namespace)
                                } else {
                                    Rectangle()
                                        .frame(width: 24, height: 2)
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
                    default:
                        EmptyView()
                    }
                }
                .animation(.easeInOut, value: viewModel.tabSelection)
            }
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
                        Text("List Questions")
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
                                        .font(viewModel.qnaTabSelection == item.id ? .robotoBold(size: 16) : .robotoRegular(size: 16))
                                        .foregroundColor(viewModel.qnaTabSelection == item.id ? .blue : Color(red: 0.63, green: 0.64, blue: 0.66))
                                    
                                    if viewModel.qnaTabSelection == item.id {
                                        RoundedRectangle(cornerRadius: 8)
                                            .frame(width: 24, height: 2)
                                            .foregroundColor(.blue)
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
                    ScrollView {
                        VStack(spacing: 22) {
                            if !viewModel.dummyQuestionList.isEmpty {
                                ForEach(0...viewModel.dummyQuestionList.count-1, id: \.self) { index in
                                    Button {
                                        viewModel.answerQuestion(at: index)
                                    } label: {
                                        QnARowView(data: viewModel.dummyQuestionList[index], hasAnswered: false)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    .tag(0)
                    
                    ScrollView {
                        VStack(spacing: 22) {
                            if !viewModel.dummyAnsweredList.isEmpty {
                                ForEach(0...viewModel.dummyAnsweredList.count-1, id: \.self) { index in
                                    Button {
                                        viewModel.unanswerQuestion(at: index)
                                    } label: {
                                        QnARowView(data: viewModel.dummyAnsweredList[index], hasAnswered: true)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color(red: 0.15, green: 0.16, blue: 0.17))
        }
    }
    
    struct QuestionBoxBottomSheet: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            VStack(spacing: 14) {
                HStack {
                    Text("Question Box")
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
                        MultilineTextField("Question here...", text: $viewModel.questionText)
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
                    viewModel.questionText = ""
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack(spacing: 13) {
                        Spacer()
                        Text("Kirim Pertanyaan")
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
                    .background((viewModel.questionText.isEmpty || !viewModel.questionText.isStringContainWhitespaceAndText()) ? Color.dinotisGray : Color.blue)
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
        
        @State var data: DummyQuestion
        @State var hasAnswered: Bool
        
        var body: some View {
            HStack(alignment: .top, spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .foregroundColor(hasAnswered ? .blue : Color(red: 0.74, green: 0.74, blue: 0.74))
                    
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
                        Text(data.name)
                            .font(.robotoMedium(size: 12))
                        
                        Spacer()
                        
                        Text(data.date, style: .time)
                            .font(.robotoBold(size: 12))
                    }
                    .foregroundColor(Color(red: 0.63, green: 0.64, blue: 0.66))
                    
                    Text(data.question)
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
                    if viewModel.isHost {
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
                                            
                                        } label: {
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
                                ForEach(viewModel.dummyChatList, id: \.id) { message in
                                    VStack(alignment: .leading, spacing: 9) {
                                        ChatHeaderView(
                                            author: message.name,
                                            isAuthorYou: message.isYou,
                                            date: message.date
                                        )
                                        ChatBubbleView(
                                            messageBody: message.message,
                                            isAuthorYou: message.isYou
                                        )
                                        .contextMenu {
                                            Button {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.4)) {
                                                    viewModel.pinnedChat = message
                                                }
                                            } label: {
                                                Label("Pin this chat", systemImage: "pin.fill")
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 7)
                                    .id(message.id)
                                }
                                
                            }
                            
                        }
                        .onChange(of: viewModel.dummyChatList.count) { _ in
                            withAnimation {
                                if let id = viewModel.dummyChatList.last?.id {
                                    scrollView.scrollTo(id, anchor: .bottom)
                                }
                            }
                        }
                        
                        HStack(alignment: .bottom) {
                            
                            HStack(alignment: .bottom) {
                                MultilineTextField("Message here...", text: $viewModel.messageText)
                                Button(action: {
                                    
                                }, label: {
                                    Image(systemName: "link")
                                        .foregroundColor(.white)
                                })
                                .padding(.vertical, 5)
                                
                                Button(action: {
                                    shouldShowImagePicker.toggle()
                                }, label: {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .foregroundColor(.white)
                                })
                                .padding(.vertical, 5)
                                
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.32, green: 0.34, blue: 0.36), lineWidth: 1)
                            )
                            
                            Button {
                                viewModel.sendMessage()
                                viewModel.messageText = ""
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
                            .background((viewModel.messageText.isEmpty || !viewModel.messageText.isStringContainWhitespaceAndText()) ? Color.dinotisGray : Color.blue)
                            .cornerRadius(11)
                            .disabled(viewModel.messageText.isEmpty || !viewModel.messageText.isStringContainWhitespaceAndText())
                            
                        }
                        .padding()
                    }
                    
                }
                .overlay(alignment: .top) {
                    if let message = viewModel.pinnedChat {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text((message.name))
                                    .font(.robotoMedium(size: 12))
                                    .foregroundColor(Color(red: 0.61, green: 0.62, blue: 0.62))
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        viewModel.pinnedChat = nil
                                    }
                                } label: {
                                    Image(systemName: "pin.fill")
                                        .foregroundColor(Color(red: 0.61, green: 0.62, blue: 0.62))
                                }
                            }
                            
                            ChatBubbleView(messageBody: message.message, isAuthorYou: message.isYou)
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
                                .foregroundColor(.white)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(Color(red: 0.15, green: 0.16, blue: 0.17))
                        )
                        .padding()
                        .transition(.move(edge: .top))
                    }
                }
            }
        }
    }
    
    struct ChatHeaderView: View {
        let author: String
        let isAuthorYou: Bool
        let date: Date
        
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
                Text(dateFormatter.string(from: date))
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
                .background(isAuthorYou ? Color.blue : Color(red: 0.26, green: 0.27, blue: 0.28))
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

struct GroupVideoCallView_Previews: PreviewProvider {
    static var previews: some View {
        GroupVideoCallView(viewModel: GroupVideoCallViewModel(backToRoot: {}, backToHome: {}))
    }
}
