//
//  AfterCallViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 02/03/22.
//

import Foundation

final class AfterCallViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	
	@Published var route: HomeRouting?
	
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: HMError?
	
	@Published var isRefreshFailed = false
	
	init(backToRoot: @escaping (() -> Void), backToHome: @escaping (() -> Void)) {
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		
	}
	
	func sublabelText() -> String {
		stateObservable.userType == 2 ? LocaleText.leaveMeetingSublabelTalent : LocaleText.leaveMeetingSublabelUser
	}
}
