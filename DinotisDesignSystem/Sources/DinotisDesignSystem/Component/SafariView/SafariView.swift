//
//  SafariView.swift
//  
//
//  Created by Gus Adi on 07/12/22.
//

#if os(iOS)

import UIKit
import SwiftUI
import SafariServices

public struct SafariViewWrapper: UIViewControllerRepresentable {

	private let url: URL
	private let configuration: SFSafariViewController.Configuration
	private let controllerConfiguration: (SFSafariViewController) -> Void

	public init(
		url: URL,
		configuration: SFSafariViewController.Configuration = .init(),
		controllerConfiguration: @escaping (SFSafariViewController) -> Void = { _ in }
	) {
		self.url = url
		self.configuration = configuration
		self.controllerConfiguration = controllerConfiguration
	}

	public func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
		let controller = SFSafariViewController(url: url, configuration: configuration)
		controllerConfiguration(controller)
		return controller
	}

	public func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariViewWrapper>) {
		return
	}
}

#endif
