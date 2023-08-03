//
//  SpeakerVideoView.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import SwiftUI
import DinotisData
import DinotisDesignSystem

struct SpeakerVideoView: View {
    @EnvironmentObject var streamManager: StreamManager
    @EnvironmentObject var hostControlsManager: HostControlsManager
    @EnvironmentObject var viewModel: TwilioLiveStreamViewModel
    @EnvironmentObject var streamViewModel: StreamViewModel
    @Binding var speaker: SpeakerVideoViewModel
    @Binding var firebaseSpeaker: [SpeakerRealtimeResponse]
    let showHostControls: Bool
    let isOnSpotlight: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.secondaryViolet

            GeometryReader { geo in
                HStack {
                    Spacer()

                    VStack {
                        Spacer()

                        Image.Dinotis.userCircleFillIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: isOnSpotlight ? 60 : geo.size.height/4)
                            .padding()
                        
                        Spacer()
                    }

                    Spacer()
                }

            }
            
            if speaker.cameraTrack != nil {
                SwiftUIVideoView(videoTrack: $speaker.cameraTrack, shouldMirror: $speaker.shouldMirrorCameraVideo)
                    .rotationEffect(.degrees(0))
                    .rotation3DEffect(.degrees(StateObservable.shared.cameraPositionUsed == .back && speaker.isYou ? 180 : 0), axis: (0, 1, 0))
            }
            
            VStack {
                HStack {
                    if (speaker.pinValue == 2) {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.white)
                            .padding(9)
                            .background(Color.DinotisDefault.primary.opacity(0.4))
                            .clipShape(Circle())
                            .padding(8)
                    }
                    
                    Spacer()
                    
                    if speaker.isMuted {
                        Image(systemName: "mic.slash")
                            .foregroundColor(.white)
                            .padding(9)
                            .background(Color.DinotisDefault.primary.opacity(0.4))
                            .clipShape(Circle())
                            .padding(8)
                    }
                }
                Spacer()
                HStack(alignment: .bottom) {
                    HStack(spacing: 3) {
                        Text(speaker.isYou ? LocaleText.you : (firebaseSpeaker.unique().first(where: { $0.identity == speaker.identity })?.identity).orEmpty())
                            .lineLimit(1)

                        Text("\((firebaseSpeaker.unique().first(where: { $0.identity == speaker.identity })?.coHost ?? false) ? "(Co-Host)" : "")")
                        Text("\((firebaseSpeaker.unique().first(where: { $0.identity == speaker.identity })?.host ?? false) ? "(Host)" : "")")
                    }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.DinotisDefault.primary.opacity(0.7))
                        )
                        .cornerRadius(2)
                        .font(.robotoMedium(size: 14))
                    Spacer()
                    
                    if showHostControls && !speaker.isYou {
                        Menu(
                            content: {
                                if !speaker.isMuted {
                                    Button(
                                        action: { hostControlsManager.muteSpeaker(identity: speaker.identity) },
                                        label: { Label(LocaleText.mute, systemImage: "mic.slash") }
                                    )
                                }
                                
                                Button(
                                    action: {
                                        let message = RoomMessage(messageType: .spotlight, toParticipantIdentity: speaker.identity)
                                        streamManager.roomManager?.localParticipant.sendMessage(message)
                                        
                                        let body = SyncSpotlightSpeaker(roomSid: (streamManager.roomManager?.roomSID).orEmpty(), userIdentity: speaker.identity)
                                        
                                        hostControlsManager.spotlightSpeaker(on: streamManager.meetingId, by: body) {
                                            streamManager.isLoading = true
                                        } finalState: {
                                            streamManager.isLoading = false
                                        }
                                    },
                                    label: { Label(streamViewModel.spotlightUser == speaker.identity ? LocaleText.removeSpotlight : LocaleText.spotlightSpeaker, systemImage: "person.crop.rectangle") }
                                )
                                
                                Button(
                                    action: { hostControlsManager.removeSpeaker(on: speaker.meetingId, by: speaker.identity) },
                                    label: { Label(LocaleText.moveToViewers, systemImage: "minus.circle") }
                                )
                                
                                Button {
                                    hostControlsManager.removeSpeakerFromRoom(on: speaker.meetingId, by: speaker.identity)
                                } label: {
                                    Label(LocaleText.remove, systemImage: "person.crop.circle.badge.xmark")
                                }
                                
                            },
                            label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 22, weight: .heavy))
                                    .frame(minWidth: 25, minHeight: 25)
                                    .padding(5)
                                    .background(
                                        Circle()
                                            .foregroundColor(.black.opacity(0.2))
                                    )
                            }
                        )
                    } else if showHostControls && speaker.isYou {
                        Menu(
                            content: {
                                Button(
                                    action: {
                                        let message = RoomMessage(messageType: .spotlight, toParticipantIdentity: speaker.identity)
                                        streamManager.roomManager?.localParticipant.sendMessage(message)
                                        
                                        let body = SyncSpotlightSpeaker(roomSid: (streamManager.roomManager?.roomSID).orEmpty(), userIdentity: speaker.identity)
                                        
                                        hostControlsManager.spotlightSpeaker(on: streamManager.meetingId, by: body) {
                                            streamManager.isLoading = true
                                        } finalState: {
                                            streamManager.isLoading = false
                                        }
                                    },
                                    label: { Label(streamViewModel.spotlightUser == speaker.identity ? LocaleText.removeSpotlight : LocaleText.spotlightMe, systemImage: "person.crop.rectangle") }
                                )

                            },
                            label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 22, weight: .heavy))
                                    .frame(minWidth: 25, minHeight: 25)
                                    .padding(5)
                                    .background(
                                        Circle()
                                            .foregroundColor(.black.opacity(0.2))
                                    )
                            }
                        )
                    }
//                    else {
//                        Menu(
//                            content: {
//                                if StateObservable.shared.spotlightedIdentity != speaker.identity {
//                                    Button(
//                                        action: { speaker.pinValue = (speaker.pinValue == 0 && speaker.pinValue != 1) ? 2 : 0 },
//                                        label: { Label((speaker.pinValue == 0 && speaker.pinValue != 1) ? "Pin Speaker" : "Unpin Speaker", systemImage: (speaker.pinValue == 0 && speaker.pinValue != 1) ? "pin.fill" : "pin.slash.fill") }
//                                    )
//                                }
//
//                                if StateObservable.shared.twilioRole == "host" {
//                                    Button(
//                                        action: {
//                                            let message = RoomMessage(messageType: .spotlight, toParticipantIdentity: speaker.identity)
//                                            streamManager.roomManager.localParticipant.sendMessage(message)
//
//                                            let body = SyncSpotlightSpeaker(roomSid: streamManager.roomManager.roomSID.orEmpty(), userIdentity: speaker.identity)
//
//                                            hostControlsManager.spotlightSpeaker(on: streamManager.meetingId, by: body) {
//                                                streamManager.isLoading = true
//                                            } finalState: {
//                                                streamManager.isLoading = false
//                                            }
//                                        },
//                                        label: { Label(StateObservable.shared.spotlightedIdentity == speaker.identity ? "Remove Spotlight" : "Spotlight Speaker", systemImage: "person.crop.rectangle") }
//                                    )
//                                }
//
//
//                            },
//                            label: {
//                                Image(systemName: "ellipsis")
//                                    .foregroundColor(Color.white)
//                                    .font(.system(size: 22, weight: .heavy))
//                                    .frame(minWidth: 25, minHeight: 25)
//                                    .padding(5)
//                                    .background(
//                                        Circle()
//                                            .foregroundColor(.DinotisDefault.primary.opacity(0.4))
//                                    )
//                            }
//                        )
//                    }
                }
                .padding(8)
            }
            
            
        }
        .overlay(
            VStack {
                if speaker.isDominantSpeaker {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.green, lineWidth: 4)
                        .onChange(of: speaker.isDominantSpeaker) { newValue in
                            speaker.pinValue = 1
                        }
                }
            }
        )
    }
}
