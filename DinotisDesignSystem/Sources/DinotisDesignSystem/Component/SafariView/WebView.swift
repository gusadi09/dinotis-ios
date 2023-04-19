//
//  WebView.swift
//  
//
//  Created by Gus Adi on 07/12/22.
//

#if os(iOS)
typealias WebViewRepresentable = UIViewRepresentable
#elseif os(macOS)
typealias WebViewRepresentable = NSViewRepresentable
#endif

#if os(iOS) || os(macOS)
import SwiftUI
import WebKit

public struct WebView: WebViewRepresentable {

	private let url: URL?
	private let configuration: (WKWebView) -> Void

	public init(
		url: URL? = nil,
		configuration: @escaping (WKWebView) -> Void = { _ in }
	) {
		self.url = url
		self.configuration = configuration
	}

	#if os(iOS)
	public func makeUIView(context: Context) -> WKWebView {
		makeView()
	}

	public func updateUIView(_ uiView: WKWebView, context: Context) {}
	#endif

	#if os(macOS)
	public func makeNSView(context: Context) -> WKWebView {
		makeView()
	}

	public func updateNSView(_ view: WKWebView, context: Context) {}
	#endif
}

public extension WebView {

	func makeView() -> WKWebView {
		let view = WKWebView()
		configuration(view)
		tryLoad(url, into: view)
		return view
	}

	func tryLoad(_ url: URL?, into view: WKWebView) {
		guard let url = url else { return }
		view.load(URLRequest(url: url))
	}
}

struct WebView_Previews: PreviewProvider {

	static var previews: some View {
		if let url = URL(string: "https://dinotis.com") {
			WebView(url: url)
		} else {
			Color.orange
		}
	}
}
#endif
