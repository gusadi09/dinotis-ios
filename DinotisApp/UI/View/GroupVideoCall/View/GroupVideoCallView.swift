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
                    .isHidden(!viewModel.isShowingToolbar, remove: !viewModel.isShowingToolbar)
                
                TabView(selection: $viewModel.index) {
                    VStack {
                        LocalUserVideoContainerView(viewModel: viewModel)
                            .padding(.horizontal)
                            .padding(.bottom)
                        
                        Spacer()
                            .frame(height: 116)
                            .isHidden(!viewModel.isShowingToolbar, remove: !viewModel.isShowingToolbar)
                    }
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
                            
//                            LazyVGrid(columns: [GridItem(.adaptive(minimum: (geo.size.width/2)-30))]) {
//                                ForEach(0...5, id: \.self) { item in
////                                        RemoteUserJoinedVideoContainerView(viewModel: viewModel, participant: item)
//                                    ZStack {
//                                        RoundedRectangle(cornerRadius: 14)
//                                            .foregroundColor(.DinotisDefault.black2)
//
//                                        Circle()
//                                            .foregroundColor(.blue)
//                                            .frame(width: 60, height: 60)
//                                    }
//                                    .frame(height: ((geo.size.width/2)-30)*246/176)
//                                }
//                            }
//                            .padding(.horizontal)
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
                    
                    ///                        View for viewer
                    ///                        HStack(spacing: 8) {
                    ///                           Image.videoCallLiveWhiteIcon
                    ///                                .resizable()
                    ///                                .scaledToFit()
                    ///                                .frame(height: 24)
                    ///
                    ///                            Text(LocalizableText.liveText)
                    ///                                .font(.robotoBold(size: 12))
                    ///                        }
                    ///                        .padding(.leading, 6)
                    ///                        .padding(.trailing, 12)
                    ///                        .padding(.vertical, 2)
                    ///                        .background(Color.DinotisDefault.red)
                    ///                        .cornerRadius(68)
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
        }
        .onDisappear {
            viewModel.onDisappear()
            AppDelegate.orientationLock = .portrait
        }
        .onChange(of: viewModel.isInit) { newValue in
            if newValue {
                viewModel.joinMeeting()
            }
        }
    }
}

fileprivate extension GroupVideoCallView {
    struct BottomToolBar: View {
        @ObservedObject var viewModel: GroupVideoCallViewModel
        
        var body: some View {
            HStack {
                Spacer()
                
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
                
                Group {
                    Spacer()
                    
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
                }
                
                Group {
                    Spacer()
                    
                    Button {
                        viewModel.isShowingChat.toggle()
                    } label: {
                        Image.videoCallChatIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: 45)
                            .foregroundColor(.white)
                    }
                }
                
                Group {
                    Spacer()
                    
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
                }
                
                Group {
                    Spacer()
                    
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
                
                Spacer()
            }
            .padding()
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
}

struct GroupVideoCallView_Previews: PreviewProvider {
    static var previews: some View {
        GroupVideoCallView(viewModel: GroupVideoCallViewModel(backToRoot: {}, backToHome: {}))
    }
}
