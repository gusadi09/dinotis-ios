//
//  CreatorRoomViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 25/01/24.
//

import DinotisData
import Foundation

final class CreatorRoomViewModel: ObservableObject {
    
    private let getUserUseCase: GetUserUseCase
    private let state = StateObservable.shared
    
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var error: String?
    @Published var isRefreshFailed = false
    
    @Published var route: HomeRouting?
    
    @Published var profesionSelect: [ProfessionData]
    
    @Published var isCreatorModeActive = false
    @Published var isShowCompleteProfileSheet = false
    @Published var profilePercentage: Double
    
    var backToHome: () -> Void
    
    init(
        profilePercentage: Double,
        profesionSelect: [ProfessionData],
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        backToHome: @escaping () -> Void
    ) {
        self.profilePercentage = profilePercentage
        self.profesionSelect = profesionSelect
        self.getUserUseCase = getUserUseCase
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
        Task {
            await getUsers()
        }
    }
    
    func onChanged(_ isShow: Bool) {
        guard profilePercentage >= 100.0 else {
            isShowCompleteProfileSheet = true
            isCreatorModeActive = false
            return
        }
        
        state.isShowGateway = isShow
    }
    
    func onStartedFetch() {
        DispatchQueue.main.async {[weak self] in
            self?.isError = false
            self?.isLoading = true
            self?.error = nil
        }
    }
    
    func getUsers() async {
        onStartedFetch()
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                
                guard (self?.profilePercentage).orZero() < (success.profilePercentage).orZero() else { return }
                
                self?.profilePercentage = success.profilePercentage.orZero()
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false

            if let error = error as? ErrorResponse {

                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.error = error.message.orEmpty()
                    self?.isError = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }

        }
    }
}
