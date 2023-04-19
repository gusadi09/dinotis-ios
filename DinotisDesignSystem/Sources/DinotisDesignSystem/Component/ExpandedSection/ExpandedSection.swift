//
//  SwiftUIView.swift
//  
//
//  Created by Gus Adi on 30/01/23.
//

import SwiftUI

public struct ExpandedSection<Header: View, Content: View>: View {

	private let header: Header
	private let content: Content

	@State public var isExpanded: Bool = false

	public init(
		@ViewBuilder header: () -> Header,
		@ViewBuilder content: () -> Content
	) {
		self.header = header()
		self.content = content()
	}

    public var body: some View {
		VStack {
			HStack {
				header

				Spacer()

				Image(
					systemName: "chevron.down"
				)
				.rotationEffect(.degrees(isExpanded ? -180 : 0))
			}
			.contentShape(Rectangle())
			.onTapGesture {
				withAnimation(.spring()) {
					isExpanded.toggle()
				}
			}

			content
				.isHidden(
					!isExpanded,
					remove: !isExpanded
				)
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 15)
				.foregroundColor(.white)
				.shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
		)
    }
}

struct preview: View {

	var body: some View {
		ExpandedSection {
				VStack {
					Text("Test")

					Text("Test")
				}
			} content: {
				VStack {
					HStack {
						Text("Test")

						Spacer()


					}
				}
				.padding(.vertical)
			}
			.padding()

	}
}

struct ExpandedSection_Previews: PreviewProvider {
    static var previews: some View {
		preview()

    }
}
