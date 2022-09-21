//
//  PresentationLayoutView.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import SwiftUI
import TwilioVideo

struct PresentationLayoutView: View {

	@EnvironmentObject var viewModel: PresentationLayoutViewModel
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass

	let spacing: CGFloat
	let role: String

	private var isPortraitOrientation: Bool {
		verticalSizeClass == .regular && horizontalSizeClass == .compact
	}

	var body: some View {
		GeometryReader { geometry in
			HStack(spacing: spacing) {
				VStack(spacing: spacing) {
					PresentationStatusView(presenterDisplayName: viewModel.presenter.displayName)
					//SpeakerVideoView(speaker: $viewModel.dominantSpeaker, showHostControls: role == "host")

					//if isPortraitOrientation {
					PresentationVideoView(videoTrack: $viewModel.presenter.presentationTrack)
					//}
				}
				// For landscape orientation only use 30% of the width for stuff that isn't the presentation video
				//.frame(width: isPortraitOrientation ? nil : geometry.size.width * 0.3)

				//if !isPortraitOrientation {
				//	PresentationVideoView(videoTrack: $viewModel.presenter.presentationTrack)
				//}
			}
			.padding(.bottom, spacing)
		}
	}
}

struct PresentationLayoutView_Previews: PreviewProvider {
	static var previews: some View {
		PresentationLayoutView(
			spacing: 6,
			role: "speaker"
		)
	}
}
