//
//  SwiftUIView.swift
//  
//
//  Created by Gus Adi on 22/06/23.
//

import SwiftUI

public struct UIVideoView: UIViewRepresentable {
    public var videoView: UIView
    public var width: CGFloat
    public var height: CGFloat
    
    public init(videoView: UIView, width: CGFloat, height: CGFloat) {
        self.videoView = videoView
        self.width = width
        self.height = height
    }
    
    public func makeUIView(context: UIViewRepresentableContext<UIVideoView>) -> UIView {
        let view = videoView
        
        view.frame = videoView.bounds
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<UIVideoView>) {}
}
