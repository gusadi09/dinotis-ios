//
//  DinotisPrimaryButton.swift
//  DinotisDesignSystem
//
//  Created by Gus Adi on 30/11/22.
//

import SwiftUI

public enum ButtonType {
	case wrappedContent
	case adaptiveScreen
	case mini
	case fixed(CGFloat)
}

public struct DinotisPrimaryButton: View {

	private let action: () -> Void
	private let textColor: Color
	private let bgColor: Color
	private let text: String
	private let type: ButtonType

	public init(
		text: String,
		type: ButtonType,
		textColor: Color,
		bgColor: Color,
		_ action: @escaping () -> Void
	) {
		self.text = text
		self.bgColor = bgColor
		self.textColor = textColor
		self.action = action
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
			}
			.buttonStyle(.plain)
		}

	}
}

struct DinotisPrimaryButton_Preview: PreviewProvider {
	static var previews: some View {
		VStack {
			DinotisPrimaryButton(
				text: "Preview Button",
				type: .wrappedContent,
				textColor: .white,
				bgColor: .blue, {}
			)
			.padding()

			DinotisPrimaryButton(
				text: "Preview Button",
				type: .adaptiveScreen,
				textColor: .white,
				bgColor: .blue, {}
			)
			.padding()
		}
	}
}
