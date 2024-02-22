//
//  File.swift
//  
//
//  Created by Garry on 26/01/23.
//

import Lottie
import SwiftUI

public struct LottieView: UIViewRepresentable {
    private var name: String
    private var loopMode: LottieLoopMode = .playOnce
    private var contentMode: UIView.ContentMode
    
    private var animationView = AnimationView()
    
    public init(
        name: String,
        loopMode: LottieLoopMode = .playOnce,
        contentMode: UIView.ContentMode = .scaleAspectFill
    ) {
        self.name = name
        self.loopMode = loopMode
        self.contentMode = contentMode
    }
    
    public func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        
        animationView.animation = Animation.named(name, bundle: .module)
        animationView.contentMode = contentMode
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
    
    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {}
}
