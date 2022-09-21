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
		uiView.loadHTMLString(htmlContent, baseURL: nil)
	}
}
