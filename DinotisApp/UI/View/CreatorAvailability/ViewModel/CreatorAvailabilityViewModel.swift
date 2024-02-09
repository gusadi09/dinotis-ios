//
//  CreatorAvailabilityViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 26/10/23.
//

import Foundation
import DinotisDesignSystem
import DinotisData
import OneSignal

final class CreatorAvailabilityViewModel: ObservableObject {
    private let creatorAvailabilityUseCase: SetCreatorAvailabilityUseCase
    private let getUserUseCase: GetUserUseCase
    private var stateObservable = StateObservable.shared
    
    @Published var isCreatorModeActive = false
    @Published var isShowCompleteProfileSheet = false
    @Published var route: HomeRouting?
    
    @Published var isShowSubscriptionSheet = false
    
    @Published var request = CreatorAvailabilityRequest(availability: false, price: 0, type: nil)
    
    @Published var subscriptionAmount = ""
    
    @Published var isRefreshFailed = false
    @Published var isLoading = false
    @Published var isError = false
    @Published var error = ""
    @Published var isSuccess = false
    
    var backToHome: () -> Void
    
    var subscriptionTypeText: String {
        switch request.type {
        case .MONTHLY:
            LocalizableText.subscriptionPaidMonthly
        case .FREE:
            LocalizableText.subscriptionPaidFree
        case nil:
            LocalizableText.profileSelectSubscriptionTypePlaceholder
        }
    }
    
    init(
        creatorAvailabilityUseCase: SetCreatorAvailabilityUseCase = SetCreatorAvailabilityDefaultUseCase(),
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        backToHome: @escaping () -> Void
    ) {
        self.backToHome = backToHome
        self.creatorAvailabilityUseCase = creatorAvailabilityUseCase
        self.getUserUseCase = getUserUseCase
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
            if let error = error as? ErrorResponse {
                
                self?.isError = true
                
                if error.statusCode.orZero() == 401 {
                    self?.error = LocaleText.sessionExpireText
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.error = error.message.orEmpty()
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }
        }
        
    }
    
    func onStartedSet() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
            self?.isError = false
            self?.error = ""
            self?.isRefreshFailed = false
            self?.isSuccess = false
        }
    }
    
    func getUser() async {
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.request = CreatorAvailabilityRequest(availability: (success.userAvailability?.availability).orFalse(), price: Int((success.userAvailability?.price).orEmpty()).orZero(), type: success.userAvailability?.type)
                
                self?.subscriptionAmount = (success.userAvailability?.price).orEmpty()
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func onGetUser() {
        Task {
            await getUser()
        }
    }
    
    func setAvailability() async {
        onStartedSet()
        
        let result = await creatorAvailabilityUseCase.execute(with: request)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.isSuccess = true
            }
            
            await getUser()
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    func routeToRoot() {
        NavigationUtil.popToRootView()
        self.stateObservable.userType = 0
        self.stateObservable.isVerified = ""
        self.stateObservable.refreshToken = ""
        self.stateObservable.accessToken = ""
        self.stateObservable.isAnnounceShow = false
        OneSignal.setExternalUserId("")
    }
}
