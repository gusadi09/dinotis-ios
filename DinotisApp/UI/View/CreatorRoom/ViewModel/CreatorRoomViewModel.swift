//
//  CreatorRoomViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 25/01/24.
//

import DinotisData
import Foundation

final class CreatorRoomViewModel: ObservableObject {
    
    private let state = StateObservable.shared
    
    @Published var route: HomeRouting?
    
    @Published var profesionSelect: [ProfessionData]
    
    @Published var isCreatorModeActive = false
    @Published var isShowCompleteProfileSheet = false
    @Published var profilePercentage: Double
    
    var backToHome: () -> Void
    
    init(
        profilePercentage: Double,
        profesionSelect: [ProfessionData],
        backToHome: @escaping () -> Void
    ) {
        self.profilePercentage = profilePercentage
        self.profesionSelect = profesionSelect
        self.backToHome = backToHome
    }
    
    func routeToEditProfile() {
        let viewModel = EditProfileViewModel(backToHome: backToHome)
        
        DispatchQueue.main.async { [weak self] in
            self?.isShowCompleteProfileSheet = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [weak self] in
            self?.route = .editTalentProfile(viewModel: viewModel)
        }
    }
    
    func onAppeared() {
        isCreatorModeActive = state.isShowGateway
    }
    
    func onChanged(_ isShow: Bool) {
        guard profilePercentage >= 100.0 else {
            isShowCompleteProfileSheet = true
            isCreatorModeActive = false
            return
        }
        
        state.isShowGateway = isShow
    }
}
