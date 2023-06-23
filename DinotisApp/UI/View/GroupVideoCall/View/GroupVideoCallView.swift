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
        VStack {
            
            Spacer()
            
            if viewModel.isJoined {
                
                VideoContainerView(viewModel: viewModel)
                
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

            
            Spacer()
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}

fileprivate extension GroupVideoCallView {
    struct VideoContainerView: View {
        
        @ObservedObject var viewModel: GroupVideoCallViewModel
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                if viewModel.isCameraOn {
                    if let video = viewModel.meeting.localUser.getVideoView() {
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
                            ImageLoader(url: viewModel.meeting.localUser.picture.orEmpty(), width: 136, height: 136)
                                .frame(width: 136, height: 136)
                                .clipShape(Circle())
                        )
                }
                
                HStack {
                    if !viewModel.meeting.localUser.fetchAudioEnabled() {
                        Image.videoCallMicrophoneActiveIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10)
                    }
                    
                    Text("\(viewModel.meeting.localUser.name) \(viewModel.meeting.localUser.canDoParticipantHostControls() ? "(host)" : "")")
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
