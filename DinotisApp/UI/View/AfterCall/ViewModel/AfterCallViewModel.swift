//
//  AfterCallViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 02/03/22.
//

import Foundation
import DinotisData

final class AfterCallViewModel: ObservableObject {
	
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	
	@Published var route: HomeRouting?
	
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?
	
	@Published var isRefreshFailed = false
	
	init(backToHome: @escaping (() -> Void)) {
		self.backToHome = backToHome
		
	}
	
	func sublabelText() -> String {
		stateObservable.userType == 2 ? LocaleText.leaveMeetingSublabelTalent : LocaleText.leaveMeetingSublabelUser
	}
}
