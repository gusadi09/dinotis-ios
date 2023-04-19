//
//  DinotisNudeButton.swift
//  
//
//  Created by Gus Adi on 30/11/22.
//

import SwiftUI

public struct DinotisNudeButton: View {

	private let action: () -> Void
	private let textColor: Color
	private let fontSize: CGFloat
	private let text: String

	public init(
		text: String,
		textColor: Color,
		fontSize: CGFloat = 10,
		_ action: @escaping () -> Void
	) {
		self.text = text
		self.textColor = textColor
		self.fontSize = fontSize
		self.action = action
	}

	public var body: some View {
		Button(action: action) {
			Text(text)
				.font(.robotoBold(size: fontSize))
				.foregroundColor(textColor)
		}
		.buttonStyle(.plain)
    }
}

struct DinotisNudeButton_Previews: PreviewProvider {
    static var previews: some View {
		DinotisNudeButton(text: "Preview Button", textColor: .blue, {})
    }
}
