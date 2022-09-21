//
//  SwiftUIPlayerView.swift
//  DinotisApp
//
//  Created by Garry on 05/08/22.
//

import SwiftUI
import TwilioLivePlayer

struct SwiftUIPlayerView: UIViewRepresentable {
	@Binding var player: Player?
	
	func makeUIView(context: Context) -> PlayerView {
		PlayerView()
	}
	
	func updateUIView(_ uiView: PlayerView, context: Context) {
		guard player?.playerView !== uiView else {
			/// If `playerView` is already set don't set it again. This prevents the view from flickering sometimes.
			return
		}
		
		player?.playerView = uiView
	}
}

