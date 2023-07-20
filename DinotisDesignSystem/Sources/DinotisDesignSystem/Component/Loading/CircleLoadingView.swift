//
//  SwiftUIView.swift
//  
//
//  Created by Irham Naufal on 20/07/23.
//

import SwiftUI

public struct CircleLoadingView: View {
    
    private let width: CGFloat
    private let height: CGFloat
    
    public init(width: CGFloat = 24, height: CGFloat = 24) {
        self.width = width
        self.height = height
    }
    
    public var body: some View {
        LottieView(
            name: "lottie-circle-white-loading",
            loopMode: .loop
        )
        .scaledToFit()
        .frame(width: width, height: height)
    }
}

struct CircleLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        CircleLoadingView()
    }
}
