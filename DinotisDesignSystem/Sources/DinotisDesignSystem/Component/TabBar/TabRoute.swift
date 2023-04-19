//
//  File.swift
//  
//
//  Created by Gus Adi on 26/01/23.
//

import Foundation
import SwiftUI

public enum TabRoute: Hashable {
	case explore
	case search
	case agenda
	case profile
}

public struct TabIconModel {
	public let icon: Image
	public let name: String
	public let assignedPage: TabRoute

	public init(icon: Image, name: String, assignedPage: TabRoute) {
		self.icon = icon
		self.name = name
		self.assignedPage = assignedPage
	}
}
