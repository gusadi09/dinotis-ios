//
//  OnboardingViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/12/22.
//

import Foundation
import DinotisData

final class OnboardingViewModel: ObservableObject {
    
    private let stateObservable = StateObservable.shared
    
    @Published var selectedContent = 0
    
    @Published var route: PrimaryRouting?
    private let repository: AuthenticationRepository
    
    init(
        repository: AuthenticationRepository = AuthenticationDefaultRepository()
    ) {
        self.repository = repository
    }
    
    func routeToUserType() {
        DispatchQueue.main.async { [weak self] in
            self?.route = .userType
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
                let vm = TabViewContainerViewModel(
                    isFromUserType: true, 
                    talentHomeVM: TalentHomeViewModel(isFromUserType: true),
                    userHomeVM: UserHomeViewModel(),
                    profileVM: ProfileViewModel(backToHome: {}),
                    searchVM: SearchTalentViewModel(backToHome: {}),
                    scheduleVM: ScheduleListViewModel(backToHome: {}, currentUserId: "")
                )
                
                DispatchQueue.main.async { [weak self] in
                    self?.route = .tabContainer(viewModel: vm)
                }
            
        } else if !isTokenEmpty &&
                    ((stateObservable.isVerified == "VerifiedNoName") &&
                     stateObservable.userType != 0) {
            let viewModel = BiodataViewModel()

            DispatchQueue.main.async { [weak self] in
                self?.route = .biodataUser(viewModel: viewModel)
            }
        }
    }
}
