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
        TabView(selection: $viewModel.index) {
            VStack {
                
                if viewModel.isJoined {
                    
                    LocalUserVideoContainerView(viewModel: viewModel)
                    
                    DinotisPrimaryButton(text: "Mute Mic", type: .adaptiveScreen, height: 45, textColor: .white, bgColor: .DinotisDefault.primary) {
                        viewModel.toggleMicrophone()
                    }
                    .padding()
                    
                    DinotisPrimaryButton(text: "Switch Camera", type: .adaptiveScreen, height: 45, textColor: .white, bgColor: .DinotisDefault.primary) {
                        viewModel.switchCamera()
                    }
                    .padding()
                    
                    
                    DinotisPrimaryButton(text: viewModel.isCameraOn ? "Disable" : "enable", type: .adaptiveScreen, height: 45, textColor: .white, bgColor: .DinotisDefault.primary) {
                        viewModel.toggleCamera()
                    }
                    .padding()
                }
                
                Text(viewModel.joined)
                
                Button {
                    viewModel.joinMeeting()
                } label: {
                    Text("Join Room")
                }
                
                Button {
                    viewModel.leaveMeeting()
                } label: {
                    Text("Leave Room")
                }

            }
            .tag(0)
            
            VStack {
                ScrollView {
                    if viewModel.isJoined {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 176))]) {
                            ForEach($viewModel.participants, id: \.id) { item in
                                RemoteUserJoinedVideoContainerView(participant: item)
                            }
                        }
                    }
                }
            }
            .tag(1)
        }
        .tabViewStyle(.page)
        .onChange(of: viewModel.index, perform: { newValue in
            if viewModel.isJoined {
                if newValue == 0 {
                    viewModel.localUser = viewModel.meeting.localUser
                } else {
                    viewModel.localUser = nil
                }
            }
        })
        .onAppear {
            viewModel.onAppear()
            AppDelegate.orientationLock = .all
        }
        .onDisappear {
            viewModel.onDisappear()
            AppDelegate.orientationLock = .portrait
        }
    }
}

fileprivate extension GroupVideoCallView {
    struct LocalUserVideoContainerView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                if viewModel.localUser != nil {
                    if viewModel.isCameraOn {
                        if let video = viewModel.localUser?.getVideoView() {
                            UIVideoView(videoView: video, width: 176, height: 246)
                                .frame(width: 176, height: 246)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .rotationEffect(.degrees(0))
                                .rotation3DEffect(.degrees(viewModel.position == .rear ? 180 : 0), axis: (0, 1, 0))
                        }
                        
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.DinotisDefault.black1)
                            .frame(width: 176, height: 246)
                            .overlay(
                                ImageLoader(url: (viewModel.localUser?.picture).orEmpty(), width: 136, height: 136)
                                    .frame(width: 136, height: 136)
                                    .clipShape(Circle())
                            )
                    }
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.DinotisDefault.black1)
                        .frame(width: 176, height: 246)
                }
                
                if viewModel.localUser != nil {
                    HStack {
                        if !(viewModel.localUser?.fetchAudioEnabled() ?? false) {
                            Image.videoCallMicrophoneActiveIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10)
                        }
                        
                        Text("\(viewModel.localUser?.name ?? "") \(viewModel.localUser?.canDoParticipantHostControls() ?? false ? "(host)" : "")")
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
        
        @Binding var participant: DyteJoinedMeetingParticipant
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
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
                
                HStack {
                    if !participant.fetchAudioEnabled() {
                        Image.videoCallMicrophoneActiveIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10)
                    }
                    
                    Text("\(participant.name) \(participant.isHost ? "(host)" : "")")
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
