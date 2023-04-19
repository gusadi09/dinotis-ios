//
//  DinotisLoadingView.swift
//  
//
//  Created by Garry on 26/01/23.
//

import SwiftUI

public enum LoadingType {
    case small
    case fullscreen
}

public struct DinotisLoadingView: View {
    private var hide: Bool
    private var type: LoadingType
    
    public init(
        _ type: LoadingType = .small,
        hide: Bool
    ) {
        self.hide = hide
        self.type = type
    }
    
    public var body: some View {
        switch type {
        case .small:
            LottieView(
                name: "dinotis-white-lottie-loading",
                loopMode: .loop
            )
            .scaledToFit()
            .padding()
            .frame(width: 120)
            .background(
                Color.black.opacity(0.5)
            )
            .cornerRadius(12)
            .isHidden(hide, remove: hide)
        case .fullscreen:
            ZStack {
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                
                LottieView(
                    name: "dinotis-white-lottie-loading",
                    loopMode: .loop
                )
                .scaledToFit()
                .frame(width: 120)
            }
            .isHidden(hide, remove: hide)
        }
    }
}

struct DinotisLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        DinotisLoadingView(hide: false)
        
        DinotisLoadingView(.fullscreen, hide: false)
    }
}
