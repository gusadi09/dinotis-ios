//
//  PasswordTextField.swift
//  
//
//  Created by Gus Adi on 02/12/22.
//

import SwiftUI

public struct PasswordTextField<Content: View>: View {

	@Binding var isSecure: Bool
	@Binding var password: String
	@Binding var errorText: [String]?
	private let placeholder: String
	let trailingContent: Content
	let onSubmit: () -> Void

	public init(
		_ placeholder: String,
		isSecure: Binding<Bool>,
		password: Binding<String>,
		errorText: Binding<[String]?>,
		onSubmit: @escaping () -> Void = { },
		@ViewBuilder _ trailingContent: () -> Content
	) {
		self.placeholder = placeholder
		self._isSecure = isSecure
		self._password = password
		self._errorText = errorText
		self.onSubmit = onSubmit
		self.trailingContent = trailingContent()
	}

    public var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				if isSecure {
					#if os(macOS)
					SecureField(placeholder, text: $password, onCommit: onSubmit)
						.textFieldStyle(.plain)
                        .font(.robotoRegular(size: 12))
						.foregroundColor(.black)
						.disableAutocorrection(true)
					#else
					SecureField(placeholder, text: $password, onCommit: onSubmit)
						.textFieldStyle(.plain)
                        .font(.robotoRegular(size: 12))
						.foregroundColor(.black)
						.disableAutocorrection(true)
						.autocapitalization(.none)
					#endif
				} else {
					#if os(macOS)
					TextField(placeholder, text: $password, onCommit: onSubmit)
						.font(.robotoRegular(size: 12))
						.textFieldStyle(.plain)
						.foregroundColor(.black)
						.disableAutocorrection(true)
					#else
					TextField(placeholder, text: $password, onCommit: onSubmit)
						.font(.robotoRegular(size: 12))
						.textFieldStyle(.plain)
						.foregroundColor(.black)
						.disableAutocorrection(true)
						.autocapitalization(.none)
					#endif
				}

				trailingContent
					.buttonStyle(.plain)
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 8)
					.foregroundColor(.white)
			)
			.overlay(
				RoundedRectangle(cornerRadius: 8)
					.stroke(Color(red: 0.792, green: 0.8, blue: 0.812), lineWidth: 1)
			)

			if let error = errorText {
				ForEach(error, id: \.self) { item in
					Text(item)
						.font(.robotoMedium(size: 10))
						.foregroundColor(.DinotisDefault.red)
						.multilineTextAlignment(.leading)
				}
			}
		}
    }
}

struct PasswordTFPreview: View {
	@State var isSecure = true

	var body: some View {
		PasswordTextField(
			"Preview TF",
			isSecure: $isSecure,
			password: .constant("PreviewPass"),
			errorText: .constant(["Error!"])
		) {
			Button {
				isSecure.toggle()
			} label: {
				Image(systemName: isSecure ? "eye.slash" : "eye")
			}

		}
	}
}

struct PasswordTextField_Previews: PreviewProvider {

    static var previews: some View {
		PasswordTFPreview()
			.padding()
    }
}
