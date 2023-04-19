//
//  PhoneNumberTextField.swift
//  
//
//  Created by Gus Adi on 02/12/22.
//

import SwiftUI

public struct PhoneNumberTextField<Content: View>: View {

	@Binding var text: String
	@Binding var errorText: [String]?
	let placeholder: String
	let content: Content
	let onSubmit: () -> Void

	public init(
		_ placeholder: String,
		text: Binding<String>,
		errorText: Binding<[String]?>,
		onSubmit: @escaping () -> Void = {},
		@ViewBuilder _ content: () -> Content
	) {
		self.placeholder = placeholder
		self._text = text
		self._errorText = errorText
		self.onSubmit = onSubmit
		self.content = content()
	}

    public var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack(spacing: 10) {

				content
					.padding([.leading, .vertical])

				Capsule()
					.foregroundColor(Color(red: 0.792, green: 0.8, blue: 0.812))
					.frame(width: 1, height: 25)

				#if os(macOS)
					TextField(placeholder, text: $text, onCommit: onSubmit)
						.font(.robotoRegular(size: 12))
						.foregroundColor(.black)
						.textFieldStyle(.plain)
						.padding([.trailing, .vertical])
				#else
					TextField(placeholder, text: $text, onCommit: onSubmit)
						.font(.robotoRegular(size: 12))
						.foregroundColor(.black)
						.textFieldStyle(.plain)
						.keyboardType(.phonePad)
						.padding([.trailing, .vertical])
				#endif

			}
			.background(
				RoundedRectangle(cornerRadius: 8)
					.foregroundColor(.white)
			)
			.overlay(
				RoundedRectangle(cornerRadius: 8)
					.stroke(Color(red: 0.792, green: 0.8, blue: 0.812), lineWidth: 1)
			)

			if let error = errorText {
				ForEach(error, id: \.self) {
					Text($0)
						.font(.robotoMedium(size: 10))
						.foregroundColor(.DinotisDefault.red)
						.multilineTextAlignment(.leading)
				}
			}
		}

    }
}

struct PhoneNumberTextField_Previews: PreviewProvider {
    static var previews: some View {
		VStack(spacing: 20) {
			PhoneNumberTextField("Phone Number", text: .constant(""), errorText: .constant(["Error"])) {
				Text("+62")
			}

			PhoneNumberTextField("Phone Number", text: .constant(""), errorText: .constant(nil)) {
				Text("+62")
			}
		}
			.padding()
    }
}
