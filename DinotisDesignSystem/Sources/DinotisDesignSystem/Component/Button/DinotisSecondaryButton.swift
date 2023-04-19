//
//  DinotisSecondaryButton.swift
//  
//
//  Created by Gus Adi on 30/11/22.
//

import SwiftUI

public struct DinotisSecondaryButton: View {
	private let action: () -> Void
	private let textColor: Color
	private let bgColor: Color
	private let strokeColor: Color
	private let text: String
	private let type: ButtonType

	public init(
		text: String,
		type: ButtonType,
		textColor: Color,
		bgColor: Color,
		strokeColor: Color,
		_ action: @escaping () -> Void
	) {
		self.text = text
		self.bgColor = bgColor
		self.textColor = textColor
		self.action = action
		self.strokeColor = strokeColor
		self.type = type
	}

	public var body: some View {
		switch type {
		case .wrappedContent:
			Button(action: action) {
				Text(text)
					.font(.robotoBold(size: 14))
					.foregroundColor(textColor)
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(bgColor)
					)
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(strokeColor, lineWidth: 1)
					)
			}
			.buttonStyle(.plain)

		case .adaptiveScreen:
			Button(action: action) {
				HStack {
					Spacer()

					Text(text)
						.font(.robotoBold(size: 14))
						.foregroundColor(textColor)

					Spacer()
				}
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 10)
						.foregroundColor(bgColor)
				)
				.overlay(
					RoundedRectangle(cornerRadius: 10)
						.stroke(strokeColor, lineWidth: 1)
				)
			}
			.buttonStyle(.plain)

		case .mini:
			Button(action: action) {
				Text(text)
					.font(.robotoBold(size: 12))
					.foregroundColor(textColor)
					.padding(10)
					.background(
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(bgColor)
					)
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(strokeColor, lineWidth: 1)
					)
			}
			.buttonStyle(.plain)
		case .fixed(let width):
			Button(action: action) {
				Text(text)
					.font(.robotoBold(size: 14))
					.foregroundColor(textColor)
					.padding()
					.frame(width: width)
					.background(
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(bgColor)
					)
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(strokeColor, lineWidth: 1)
					)
			}
			.buttonStyle(.plain)
		}

	}
}

struct DinotisSecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
		VStack {
			DinotisSecondaryButton(
				text: "Preview Button",
				type: .wrappedContent,
				textColor: .blue,
				bgColor: .blue.opacity(0.1),
				strokeColor: .blue,
				{}
			)
			.padding()

			DinotisSecondaryButton(
				text: "Preview Button",
				type: .adaptiveScreen,
				textColor: .blue,
				bgColor: .blue.opacity(0.1),
				strokeColor: .blue,
				{}
			)
			.padding()
		}
    }
}
