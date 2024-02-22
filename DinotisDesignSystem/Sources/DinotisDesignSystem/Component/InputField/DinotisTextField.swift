//
//  DinotisTextField.swift
//  
//
//  Created by Gus Adi on 05/12/22.
//

import SwiftUI

public struct DinotisTextField<Content: View>: View {

	@Binding var text: String
	@Binding var errorText: [String]?
	let label: String?
	let placeholder: String
	let leadingIcon: Image?
	let onSubmit: () -> Void
	let trailingButton: Content
	let tfDisabled: Bool
    
    @FocusState var focused: Bool

	public init(
		_ placeholder: String,
		disabled: Bool = false,
		label: String?,
		text: Binding<String>,
		errorText: Binding<[String]?>,
		onSubmit: @escaping () -> Void = {},
		leadingIcon: Image? = nil,
		@ViewBuilder trailingButton: @escaping () -> Content = { EmptyView() }
	) {
		self.placeholder = placeholder
		self.tfDisabled = disabled
		self.label = label
		self._text = text
		self._errorText = errorText
		self.onSubmit = onSubmit
		self.trailingButton = trailingButton()
		self.leadingIcon = leadingIcon
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			if let label = label {
				Text(label)
					.font(.robotoMedium(size: 12))
                    .foregroundColor(.DinotisDefault.black1)
			}

			HStack(spacing: 10) {

				if let icon = leadingIcon {
					icon
						.resizable()
						.scaledToFit()
						.frame(height: 16)
						.padding(.leading)
				}

				Group {
					#if os(macOS)
					TextField(placeholder, text: $text, onCommit: onSubmit)
						.font(.robotoRegular(size: 12))
						.foregroundColor(.black)
						.textFieldStyle(.plain)
                        .focused($focused)
						.padding()
					#else
					TextField(placeholder, text: $text, onCommit: onSubmit)
						.font(.robotoRegular(size: 12))
						.foregroundColor(.black)
						.textFieldStyle(.plain)
						.padding()
					#endif
				}
                .focused($focused)
				.disabled(tfDisabled)

				trailingButton
					.buttonStyle(.plain)
					.padding(.trailing, 10)

			}
			.background(
				RoundedRectangle(cornerRadius: 8)
					.foregroundColor(.white)
			)
			.overlay(
				RoundedRectangle(cornerRadius: 8)
                    .stroke(focused ? Color.DinotisDefault.primary : Color(red: 0.792, green: 0.8, blue: 0.812), lineWidth: 1)
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
        .tint(Color.DinotisDefault.primary)
	}
}

struct DinotisTFPreview: View {
	@State var text = ""
	@State var error: [String]? = nil

	var body: some View {
		DinotisTextField(
			"TextField Preview...",
			label: "Preview Field",
			text: $text,
			errorText: $error,
			onSubmit: {
				error = error != nil ? ["Error!"] : nil
			},
			leadingIcon: Image(systemName: "mail"),
			trailingButton: {
				DinotisPrimaryButton(text: "Preview", type: .mini, textColor: .white, bgColor: .DinotisDefault.primary, { error = error == nil ? ["Error!"] : nil })
			}
		)

	}
}

struct DinotisTextField_Previews: PreviewProvider {
    static var previews: some View {
		DinotisTFPreview()
			.padding()
    }
}
