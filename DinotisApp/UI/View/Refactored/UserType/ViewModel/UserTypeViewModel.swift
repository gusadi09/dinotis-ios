//
//  UserTypeViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation

final class UserTypeViewModel: ObservableObject {
	
	private let repository: AuthenticationRepository
	
	private let stateObservable = StateObservable.shared
	
	@Published var route: PrimaryRouting?
	
	init(repository: AuthenticationRepository = AuthenticationDefaultRepository()) {
		self.repository = repository
	}
	
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
			self?.route = .talentLogin(viewModel: viewModel)
		}
	}
	
	func checkingSession() {
		if !stateObservable.accessToken.isEmpty {
			loginSessionChecking()
		}
	}
	
	func loginSessionChecking() {
		let isTokenEmpty = repository.loadFromKeychain(forKey: KeychainKey.accessToken).isEmpty
		
		if !isTokenEmpty &&
				((stateObservable.isVerified == "Verified") &&
				 stateObservable.userType != 0) {
			if stateObservable.userType == 2 {
				let homeViewModel = TalentHomeViewModel(backToRoot: { self.route = nil })
				
				DispatchQueue.main.async { [weak self] in
					self?.route = .homeTalent(viewModel: homeViewModel)
				}
				
			} else if stateObservable.userType == 3 {
				let homeViewModel = UserHomeViewModel(backToRoot: { self.route = nil })
				
				DispatchQueue.main.async { [weak self] in
					self?.route = .homeUser(viewModel: homeViewModel)
				}
				
			}
			
		}
	}
	
}
