//
//  ReviewListViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 06/10/23.
//

import DinotisData
import Foundation
import OneSignal

final class ReviewListViewModel: ObservableObject {
    
    private let getInboxReviewUseCase: GetInboxReviewsUseCase
    
    @Published var stateObservable = StateObservable.shared
    @Published var tabSections: [ReviewListFilterType] = [
        .desc, .asc, .highest, .lowest
    ]
    @Published var currentSection: ReviewListFilterType = .desc
    
    @Published var data: [InboxReviewData] = []
    @Published var counter = "0"
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var isRefreshFailed = false
    @Published var error = ""
    
    init(getInboxReviewUseCase: GetInboxReviewsUseCase = GetInboxReviewsDefaultUseCase()) {
        self.getInboxReviewUseCase = getInboxReviewUseCase
    }
    
    func fetchStarted() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
            self?.isError = false
            self?.isRefreshFailed = false
            self?.error = ""
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
    
    func onLoadReviews(section: ReviewListFilterType) {
        Task {
            await getInboxReview(section: section)
        }
    }
    
    @MainActor
    func getInboxReview(section: ReviewListFilterType) async {
        fetchStarted()
        
        let result = await getInboxReviewUseCase.execute(by: section)
        
        switch result {
        case .success(let response):
            self.isLoading = false
            
            self.data = response.data ?? []
            self.counter = response.counter ?? "0"
        case .failure(let error):
            handleDefaultError(error: error)
        }
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
}
