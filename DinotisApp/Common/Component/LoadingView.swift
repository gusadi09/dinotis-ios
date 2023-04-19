//
//  File.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/04/22.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
	
	@Binding var isAnimating: Bool
	let color: UIColor
	let style: UIActivityIndicatorView.Style
	
	func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
		let indicator = UIActivityIndicatorView(style: style)
		indicator.color = color
		indicator.tintColor = .white
		return indicator
	}
	
	func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
		isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
	}
}

struct LoadingView: View {
	
	@Binding var isAnimating: Bool
    var isFullBackground = false
	
	var body: some View {
		VStack {
            if isFullBackground {
                ZStack {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    
                    ActivityIndicator(isAnimating: $isAnimating, color: .white, style: .medium)
                }
            } else {
                Spacer()
                HStack {
                    Spacer()
                    ActivityIndicator(isAnimating: $isAnimating, color: .white, style: .medium)
                        .padding(40)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                    Spacer()
                }
                Spacer()
            }
		}
	}
}
