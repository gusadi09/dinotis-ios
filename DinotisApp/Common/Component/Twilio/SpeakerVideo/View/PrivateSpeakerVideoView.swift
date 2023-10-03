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
    
    @Binding var photoUrl: String
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isPotrait: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
    
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

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
                        
                        if photoUrl.isEmpty {
                            Image.Dinotis.userCircleFillIcon
                                .resizable()
                                .scaledToFit()
                                .frame(height: isPad ? (isMainView ? 200 : 60) : (isMainView ? 150 : 50))
                                .padding()
                        } else {
                            ImageLoader(url: photoUrl, width: isPad ? (isMainView ? 200 : 60) : (isMainView ? 150 : 50), height: isPad ? (isMainView ? 200 : 60) : (isMainView ? 150 : 50))
                                .scaledToFit()
                                .frame(height: isPad ? (isMainView ? 200 : 60) : (isMainView ? 150 : 50))
                                .clipShape(Circle())
                                .padding()
                        }

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
                                .padding(isMainView ? 20 : 8)
                                .padding(.top, isMainView ? (isPotrait ? 15 : 0) : 0)
						}
					}
					Spacer()
				}
			}
		}
	}
}

