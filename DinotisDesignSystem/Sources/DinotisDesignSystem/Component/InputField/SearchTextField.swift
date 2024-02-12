//
//  SearchTextField.swift
//  
//
//  Created by Gus Adi on 05/12/22.
//

import SwiftUI

public struct SearchTextField: View {
    
    @Binding var text: String
    let placeholder: String
    let onSubmit: () -> Void
    
    @FocusState private var focused: Bool
    
    public init(
        _ placeholder: String,
        text: Binding<String>,
        focused: FocusState<Bool> = .init(),
        onSubmit: @escaping () -> Void = {}
    ) {
        self.placeholder = placeholder
        self._text = text
        self.onSubmit = onSubmit
        self._focused = focused
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 10) {
            
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(height: 16)
                .padding(.leading)
            
            TextField(placeholder, text: $text, onCommit: onSubmit)
                .font(.robotoRegular(size: 12))
                .textFieldStyle(.plain)
                .focused($focused)
                .tint(.DinotisDefault.primary)
                .foregroundColor(.black)
                .padding([.trailing, .vertical])
            
            if !text.isEmpty {
                Button {
                    withAnimation {
                        text = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                        .foregroundColor(.DinotisDefault.black3)
                        .padding(.trailing)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(focused ? Color.DinotisDefault.primary : Color(red: 0.792, green: 0.8, blue: 0.812), lineWidth: 1)
        )

	}
}

struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
		SearchTextField("Test Search Bar", text: .constant(""))
			.padding()
    }
}
