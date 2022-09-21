//
//  RefreshableScrollView.swift
//  DinotisApp
//
//  Created by Gus Adi on 10/10/21.
//

import Foundation
import SwiftUI

struct RefreshableScrollView<Content:View>: View {
	init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
		self.content = content
		self.refreshAction = action
	}
	var body: some View {
		GeometryReader { geometry in
			ScrollView(showsIndicators: false) {
				content()
					.anchorPreference(key: OffsetPreferenceKey.self, value: .top) {
						geometry[$0].y
					}
			}
			.onPreferenceChange(OffsetPreferenceKey.self) { offset in
				if offset > threshold {
					refreshAction()
				}
			}
		}
	}
	
	// MARK: - Private
	
	private var content: () -> Content
	private var refreshAction: () -> Void
	private let threshold:CGFloat = 50.0
}

private struct OffsetPreferenceKey: PreferenceKey {
	static var defaultValue: CGFloat = 0
	
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = nextValue()
	}
}
