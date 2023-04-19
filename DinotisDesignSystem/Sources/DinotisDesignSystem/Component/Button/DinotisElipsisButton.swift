//
//  DinotisElipsisButton.swift
//  
//
//  Created by Gus Adi on 01/12/22.
//

import SwiftUI

public enum ElipsisButtonType {
	case primary
	case secondary
}

public struct DinotisElipsisButton: View {

	private let action: () -> Void
	private let iconColor: Color
	private let bgColor: Color
	private let strokeColor: Color?
	private let icon: Image
	private let iconSize: CGFloat?
	private let type: ElipsisButtonType
	private let padding: CGFloat?

	public init(
		icon: Image,
		iconColor: Color,
		bgColor: Color,
		strokeColor: Color? = nil,
		iconSize: CGFloat?,
		type: ElipsisButtonType = .primary,
		padding: CGFloat? = nil,
		_ action: @escaping () -> Void
	) {
		self.icon = icon
		self.iconColor = iconColor
		self.bgColor = bgColor
		self.strokeColor = strokeColor
		self.action = action
		self.iconSize = iconSize
		self.type = type
		self.padding = padding
	}

    public var body: some View {
		switch type {
		case .primary:
			Button(action: action) {
				if let padding = padding {
					icon
						.renderingMode(.template)
						.resizable()
						.scaledToFit()
						.foregroundColor(iconColor)
						.frame(height: iconSize)
						.padding(padding)
						.background(
							Circle()
								.foregroundColor(bgColor)
						)
				} else {
					icon
						.renderingMode(.template)
						.resizable()
						.scaledToFit()
						.foregroundColor(iconColor)
						.frame(height: iconSize)
						.padding()
						.background(
							Circle()
								.foregroundColor(bgColor)
						)
				}

			}
			.buttonStyle(.plain)

		case .secondary:
			Button(action: action) {
				if let padding = padding {
					icon
						.renderingMode(.template)
						.resizable()
						.scaledToFit()
						.foregroundColor(iconColor)
						.frame(height: iconSize)
						.padding(padding)
						.background(
							Circle()
								.foregroundColor(bgColor)
						)
						.overlay(
							Circle()
								.stroke(strokeColor ?? .clear, lineWidth: 1)
						)
				} else {
					icon
						.renderingMode(.template)
						.resizable()
						.scaledToFit()
						.foregroundColor(iconColor)
						.frame(height: iconSize)
						.padding()
						.background(
							Circle()
								.foregroundColor(bgColor)
						)
						.overlay(
							Circle()
								.stroke(strokeColor ?? .clear, lineWidth: 1)
						)
				}

			}
			.buttonStyle(.plain)

		}

    }
}

struct DinotisElipsisButton_Previews: PreviewProvider {
    static var previews: some View {
		VStack {
			DinotisElipsisButton(
				icon: .init(systemName: "plus"),
				iconColor: .blue,
				bgColor: .blue.opacity(0.2),
				strokeColor: .blue,
				iconSize: 35,
				type: .secondary,
				{}
			)

			DinotisElipsisButton(
				icon: .init(systemName: "plus"),
				iconColor: .white,
				bgColor: .blue,
				iconSize: 35,
				type: .primary,
				{}
			)
		}
		.padding()
    }
}
