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
    let isShowName: Bool
	
	var body: some View {
		ZStack(alignment: .center) {
            Color.DinotisDefault.black1

			GeometryReader { geo in
				HStack {
					Spacer()

					VStack {
						Spacer()

						Circle()
                            .foregroundColor(.blue)
							.scaledToFit()
							.frame(height: 140)
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
				Spacer()
				HStack(alignment: .bottom) {
                    HStack(spacing: 4) {
                        (speaker.isMuted ? Image.videoCallMicOffStrokeIcon : Image.videoCallMicOnStrokeIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text(speaker.isYou ? LocaleText.you : (firebaseSpeaker.unique().first(where: { $0.identity == speaker.identity })?.identity).orEmpty())
                            .lineLimit(1)
                        
                        Text("\((firebaseSpeaker.unique().first(where: { $0.identity == speaker.identity })?.coHost ?? false) ? "(Co-Host)" : "")")
                        Text("\((firebaseSpeaker.unique().first(where: { $0.identity == speaker.identity })?.host ?? false) ? "(Host)" : "")")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .foregroundColor(.DinotisDefault.black2.opacity(0.4))
                    )
                    .cornerRadius(2)
                    .font(.robotoMedium(size: 14))
                    Spacer()
				}
				.padding(8)
                .isHidden(!isShowName)
			}
		}
		.overlay(
			VStack {
				if speaker.isDominantSpeaker {
					RoundedRectangle(cornerRadius: 18)
						.stroke(Color.green, lineWidth: 4)
						.onChange(of: speaker.isDominantSpeaker) { newValue in
							speaker.pinValue = 1
						}
				} 
			}
		)
	}
}
