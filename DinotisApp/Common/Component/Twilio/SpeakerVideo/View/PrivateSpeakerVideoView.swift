//
//  PrivateSpeakerVideoView.swift
//  DinotisApp
//
//  Created by Gus Adi on 09/09/22.
//

import SwiftUI

struct PrivateSpeakerVideoView: View {
	@EnvironmentObject var streamManager: PrivateStreamManager
	@Binding var speaker: PrivateSpeakerVideoViewModel
    @Binding var isCamEnabled: Bool

	let isMainView: Bool
	let isLocal: Bool

	var body: some View {
		ZStack(alignment: .center) {
			Color.black

			GeometryReader { geo in
				HStack {
					Spacer()

					VStack {
						Spacer()

						Image.Dinotis.userCircleFillIcon
							.resizable()
							.scaledToFit()
							.frame(height: isMainView ? geo.size.height/12 : geo.size.height/4)
							.padding()

						Spacer()
					}

					Spacer()
				}

			}

            if isCamEnabled {
				SwiftUIVideoView(videoTrack: $speaker.cameraTrack, shouldMirror: $speaker.shouldMirrorCameraVideo)
            }

			if !isLocal {
				VStack {
					HStack {
						Spacer()

						if speaker.isMuted {
							Image(systemName: "mic.slash")
								.resizable()
								.scaledToFit()
								.frame(height: isMainView ? 20 : 10)
								.foregroundColor(.white)
								.padding(9)
								.background(Color.DinotisDefault.primary.opacity(0.4))
								.clipShape(Circle())
								.padding(8)
						}
					}
					Spacer()
				}
			}
		}
	}
}

