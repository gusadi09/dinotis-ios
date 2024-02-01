//
//  CreatorRoomViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 25/01/24.
//

import DinotisData
import Foundation

final class CreatorRoomViewModel: ObservableObject {
    
    @Published var route: HomeRouting?
    
    @Published var profesionSelect: [ProfessionData]
    
    @Published var isCreatorModeActive = false
    @Published var isShowCompleteProfileSheet = false
    
    var backToHome: () -> Void
    
    init(
        profesionSelect: [ProfessionData],
        backToHome: @escaping () -> Void
    ) {
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
    
    
}
