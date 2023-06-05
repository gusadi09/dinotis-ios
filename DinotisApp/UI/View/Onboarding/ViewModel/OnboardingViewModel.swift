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
    
    func routeToUserType() {
        DispatchQueue.main.async { [weak self] in
            self?.route = .userType
        }
    }
    
    func checkingSession() {
        if !stateObservable.accessToken.isEmpty {
            routeToUserType()
        }
    }
}
