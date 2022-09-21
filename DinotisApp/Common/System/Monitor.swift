//
//  Monitor.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/11/21.
//

import Foundation
import Network
import SwiftUI

// An enum to handle the network status
enum NetworkStatus: String {
	case connected
	case disconnected
}

class Monitor: ObservableObject {
	static let shared = Monitor()
	
	private let monitor = NWPathMonitor()
	private let queue = DispatchQueue(label: "Monitor")
	
	@Published var status: NetworkStatus = .connected
	
	init() {
		monitorHandler()
	}
	
	func monitorHandler() {
		monitor.pathUpdateHandler = { [weak self] path in
			guard let self = self else { return }
			
			DispatchQueue.main.async {
				if path.status == .satisfied {
					self.status = .connected
				} else {
					self.status = .disconnected
				}
			}
		}
		monitor.start(queue: queue)
	}
}
