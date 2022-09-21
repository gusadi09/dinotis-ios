//
//  LottieView.swift
//  DinotisApp
//
//  Created by Gus Adi on 05/04/22.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
	var name: String
	var loopMode: LottieLoopMode = .playOnce
	
	var animationView = AnimationView()
	
	func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
		let view = UIView(frame: .zero)
		
		animationView.animation = Animation.named(name)
		animationView.contentMode = .scaleAspectFill
		animationView.loopMode = loopMode
		animationView.play()
		
		animationView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(animationView)
		
		NSLayoutConstraint.activate([
			animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
			animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
		])
		
		return view
	}
	
	func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {}
}
