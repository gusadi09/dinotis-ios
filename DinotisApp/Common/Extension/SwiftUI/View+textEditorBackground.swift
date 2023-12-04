//
//  View+textEditorBackground.swift
//  DinotisApp
//
//  Created by Irham Naufal on 01/12/23.
//

import SwiftUI

extension View {
    func textEditorBackground(_ color: Color) -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden)
                .background(color)
        } else {
            UITextView.appearance().backgroundColor = .clear
            return self.background(color)
        }
    }
}
