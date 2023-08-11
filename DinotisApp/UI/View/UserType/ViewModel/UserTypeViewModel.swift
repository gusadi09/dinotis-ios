//
//  UserTypeViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import DinotisData

final class UserTypeViewModel: ObservableObject {
	
	private let repository: AuthenticationRepository
	
	private let stateObservable = StateObservable.shared
	
	@Published var route: PrimaryRouting?
	
	init(
		repository: AuthenticationRepository = AuthenticationDefaultRepository()
	) {
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
			self?.route = .userLogin(viewModel: viewModel)
		}
	}
	
	func checkingSession() {
        Task {
            if !stateObservable.accessToken.isEmpty {
                await loginSessionChecking()
            }
        }
	}
	
	func loginSessionChecking() async {
		let isTokenEmpty = await repository.loadFromKeychain(forKey: KeychainKey.accessToken).isEmpty
		
		if !isTokenEmpty &&
				((stateObservable.isVerified == "Verified") &&
				 stateObservable.userType != 0) {
			if stateObservable.userType == 2 {
                let homeViewModel = TalentHomeViewModel(isFromUserType: true, backToRoot: { self.route = nil })
				
				DispatchQueue.main.async { [weak self] in
					self?.route = .homeTalent(viewModel: homeViewModel)
				}
				
			} else if stateObservable.userType == 3 {
				let vm = TabViewContainerViewModel(
                    isFromUserType: true,
                    userHomeVM: UserHomeViewModel(backToRoot: {self.route = nil}),
					profileVM: ProfileViewModel(backToRoot: {self.route = nil}, backToHome: {}),
					searchVM: SearchTalentViewModel(backToRoot: {self.route = nil}, backToHome: {}),
                    scheduleVM: ScheduleListViewModel(backToRoot: {self.route = nil}, backToHome: {}, currentUserId: ""),
					backToRoot: {self.route = nil}
				)
				
				DispatchQueue.main.async { [weak self] in
					self?.route = .tabContainer(viewModel: vm)
				}
				
			}
			
		} else if !isTokenEmpty &&
					((stateObservable.isVerified == "VerifiedNoName") &&
					 stateObservable.userType != 0) {
            let viewModel = BiodataViewModel(backToRoot: { self.route = nil })

			DispatchQueue.main.async { [weak self] in
				self?.route = .biodataUser(viewModel: viewModel)
			}
		}
	}
	
}
