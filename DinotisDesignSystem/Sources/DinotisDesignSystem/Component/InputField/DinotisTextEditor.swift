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
    let stroke: Color
	let label: String?
	let placeholder: String
	let onSubmit: () -> Void
    
    @FocusState private var focused: Bool

	public init(
		_ placeholder: String,
		label: String?,
		text: Binding<String>,
		errorText: Binding<[String]?>,
        stroke: Color = Color(red: 0.792, green: 0.8, blue: 0.812),
		onSubmit: @escaping () -> Void = {}
	) {
		self.placeholder = placeholder
		self.label = label
		self._text = text
		self._errorText = errorText
        self.stroke = stroke
		self.onSubmit = onSubmit
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			if let label = label {
				Text(label)
					.font(.robotoMedium(size: 12))
					.foregroundColor(.black)
			}

            ZStack(alignment: .topLeading) {

				#if os(macOS)
				TextEditor(text: $text)
					.font(.robotoRegular(size: 12))
					.foregroundColor(.black)
					.textFieldStyle(.plain)
					.frame(height: 100)
                    .focused($focused)
				#else
				TextEditor(text: $text)
					.font(.robotoRegular(size: 12))
					.foregroundColor(.black)
					.textFieldStyle(.plain)
					.frame(height: 100)
                    .focused($focused)
				#endif
                
                if text.isEmpty && !focused {
                    Text(placeholder)
                        .font(.robotoRegular(size: 12))
                        .foregroundColor(.DinotisDefault.black3)
                        .padding(4)
                        .padding(.top, 4)
                        .onTapGesture {
                            focused = true
                        }
                }
			}
			.padding(5)
			.background(
				RoundedRectangle(cornerRadius: 8)
					.foregroundColor(.white)
			)
			.overlay(
				RoundedRectangle(cornerRadius: 8)
					.stroke(stroke, lineWidth: 1)
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
