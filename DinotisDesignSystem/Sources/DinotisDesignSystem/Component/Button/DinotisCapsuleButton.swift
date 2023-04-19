//
//  DinotisCapsuleButton.swift
//  
//
//  Created by Gus Adi on 30/11/22.
//

import SwiftUI

public struct DinotisCapsuleButton: View {

	private let action: () -> Void
	private let textColor: Color
	private let bgColor: Color
	private let text: String
	private let fontSize: CGFloat

	public init(
		text: String,
		textColor: Color,
		bgColor: Color,
		fontSize: CGFloat = 10,
		_ action: @escaping () -> Void
	) {
		self.text = text
		self.bgColor = bgColor
		self.textColor = textColor
		self.fontSize = fontSize
		self.action = action
	}

	public var body: some View {
		Button(action: action) {
			Text(text)
				.padding(10)
                .padding(.horizontal, 6)
				.font(.robotoBold(size: fontSize))
				.foregroundColor(textColor)
				.background(
					Capsule()
						.foregroundColor(bgColor)
				)

		}
		.buttonStyle(.plain)
    }
}

struct DinotisCapsuleButton_Previews: PreviewProvider {
    static var previews: some View {
		DinotisCapsuleButton(text: "Preview Capsule", textColor: .white, bgColor: .blue, {})
			.padding()
    }
}
