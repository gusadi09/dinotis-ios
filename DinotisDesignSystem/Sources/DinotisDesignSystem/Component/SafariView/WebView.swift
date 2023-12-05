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
    private let accessToken: String?
    private let refreshToken: String?
    private let userRole: String?
    private let domain: String?

	public init(
		url: URL? = nil,
        accessToken: String? = nil,
        refreshToken: String? = nil,
        userRole: String? = nil,
        domain: String? = nil,
		configuration: @escaping (WKWebView) -> Void = { _ in }
	) {
		self.url = url
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userRole = userRole
        self.domain = domain
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
        
        if let domain = domain, let accessToken = accessToken, let refreshToken = refreshToken, let role = userRole {
            let cookie = HTTPCookie(properties: [
                .domain: domain,
                .path: "/",
                .name: "access-token",
                .value: accessToken,
                .expires: Date(timeIntervalSinceNow: 31556926)
            ]) ?? HTTPCookie()
            
            let cookie2 = HTTPCookie(properties: [
                .domain: domain,
                .path: "/",
                .name: "refresh-token",
                .value: refreshToken,
                .expires: Date(timeIntervalSinceNow: 31556926)
            ]) ?? HTTPCookie()
            
            let cookie3 = HTTPCookie(properties: [
                .domain: domain,
                .path: "/",
                .name: "current-role",
                .value: role,
                .expires: Date(timeIntervalSinceNow: 31556926)
            ]) ?? HTTPCookie()
            
            view.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            view.configuration.websiteDataStore.httpCookieStore.setCookie(cookie2)
            view.configuration.websiteDataStore.httpCookieStore.setCookie(cookie3)
        }
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
