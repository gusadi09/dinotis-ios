//
//  UserTypeViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import DinotisData

final class UserTypeViewModel: ObservableObject {
	
	private let stateObservable = StateObservable.shared
	
	@Published var route: PrimaryRouting?
    
	func goToUserLogin() {
		let viewModel = LoginViewModel(backToRoot: { self.route = nil })
		stateObservable.userType = 3
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .userLogin(viewModel: viewModel)
		}
	}
	
	func goToTalentLogin() {
		let viewModel = LoginViewModel(backToRoot: { self.route = nil })
		stateObservable.userType = 2
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .userLogin(viewModel: viewModel)
		}
	}
	
}
