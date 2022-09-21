//
//  DinotisSheet.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/09/22.
//

import SwiftUI
import SlideOverCard

extension View {
	public func dinotisSheet<Content: View, Style: ShapeStyle>(
		isPresented: Binding<Bool>,
		onDismiss: (() -> Void)? = nil,
		options: SOCOptions = [],
		style: SOCStyle<Style> = SOCStyle(),
		fraction: CGFloat = 0.8,
		@ViewBuilder content: @escaping () -> Content
	) -> some View {
		if #available(iOS 16.0, *) {
			return self.sheet(isPresented: isPresented, onDismiss: {
				(onDismiss ?? {})()
			}) {
					content()
						.padding()
						.padding(.vertical)
						.presentationDetents([.fraction(fraction), .large])
			}
		} else {
			return self.slideOverCard(isPresented: isPresented, onDismiss: onDismiss, options: options, style: style, content: content)
		}
	}

	public func dinotisSheet<Content: View, Style: ShapeStyle, Identify: Identifiable>(
		item: Binding<Identify?>,
		onDismiss: (() -> Void)? = nil,
		options: SOCOptions = [],
		style: SOCStyle<Style> = SOCStyle(),
		@ViewBuilder content: @escaping (Identify) -> Content
	) -> some View {
		if #available(iOS 16.0, *) {
			return self.sheet(item: item, onDismiss: onDismiss, content: content)
		} else {
			return self.slideOverCard(item: item, onDismiss: onDismiss, options: options, style: style, content: content)
		}
	}
}
