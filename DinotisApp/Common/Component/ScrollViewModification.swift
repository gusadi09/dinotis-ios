//
//  ScrollViewModification.swift
//  DinotisApp
//
//  Created by Gus Adi on 23/10/21.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
	static var defaultValue: CGPoint = .zero
	
	static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

struct ScrollViews<Content: View>: View {
	let axes: Axis.Set
	let showsIndicators: Bool
	let offsetChanged: (CGPoint) -> Void
	let content: Content
	
	init(
		axes: Axis.Set = .vertical,
		showsIndicators: Bool = true,
		offsetChanged: @escaping (CGPoint) -> Void = { _ in },
		@ViewBuilder content: () -> Content
	) {
		self.axes = axes
		self.showsIndicators = showsIndicators
		self.offsetChanged = offsetChanged
		self.content = content()
	}
	
	var body: some View {
		ScrollView(axes, showsIndicators: showsIndicators) {
			GeometryReader { geometry in
				Color.clear.preference(
					key: ScrollOffsetPreferenceKey.self,
					value: geometry.frame(in: .named("scrollView")).origin
				)
			}.frame(width: 0, height: 0)
			content
		}
		.coordinateSpace(name: "scrollView")
		.onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: offsetChanged)
	}
}
