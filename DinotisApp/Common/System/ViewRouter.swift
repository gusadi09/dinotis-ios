//
//  ViewRouter.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/11/21.
//

import Foundation

enum AppView {
	case usertype, home
}

class ViewRouter: ObservableObject {
	// here you can decide which view to show at launch
	@Published var currentView: AppView = .usertype
}
