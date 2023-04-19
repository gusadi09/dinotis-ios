//
//  HTMLViewer.swift
//  DinotisApp
//
//  Created by Gus Adi on 17/05/22.
//

import WebKit
import SwiftUI

struct HTMLStringView: UIViewRepresentable {
	var htmlContent: String

	func makeUIView(context: Context) -> WKWebView {
		return WKWebView()
	}

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let cssString = """
@font-face {
    font-family: 'Roboto';
    src: url('https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&display=swap');
}

body {
    font-family: 'Roboto', sans-serif;
    font-size: 24px;
}
"""
        
        let htmlWithStyle = "<style>\(cssString)</style>\(htmlContent)"
        
		uiView.loadHTMLString(htmlWithStyle, baseURL: nil)
	}
}
