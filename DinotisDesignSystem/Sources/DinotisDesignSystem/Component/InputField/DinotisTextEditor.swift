//
//  DinotisTextEditor.swift
//  
//
//  Created by Gus Adi on 05/12/22.
//

import SwiftUI

public struct DinotisTextEditor: View {

	@Binding var text: String
	@Binding var errorText: [String]?
	let label: String?
	let placeholder: String
	let onSubmit: () -> Void

	public init(
		_ placeholder: String,
		label: String?,
		text: Binding<String>,
		errorText: Binding<[String]?>,
		onSubmit: @escaping () -> Void = {}
	) {
		self.placeholder = placeholder
		self.label = label
		self._text = text
		self._errorText = errorText
		self.onSubmit = onSubmit
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			if let label = label {
				Text(label)
					.font(.robotoMedium(size: 12))
					.foregroundColor(.black)
			}

			ZStack {

				#if os(macOS)
				TextEditor(text: $text)
					.font(.robotoRegular(size: 12))
					.foregroundColor(.black)
					.textFieldStyle(.plain)
					.frame(height: 100)
				#else
				TextEditor(text: $text)
					.font(.robotoRegular(size: 12))
					.foregroundColor(.black)
					.textFieldStyle(.plain)
					.frame(height: 100)
				#endif

			}
			.padding(5)
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

struct DinotisTextEditorPreview: View {

	@State var text = ""

	var body: some View {
		DinotisTextEditor("Preview Editor", label: "Preview Area", text: $text, errorText: .constant(nil))
	}
}

struct DinotisTextEditor_Previews: PreviewProvider {
    static var previews: some View {
		DinotisTextEditorPreview()
			.padding()
    }
}
