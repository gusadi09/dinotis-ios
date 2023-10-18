//
//  InboxViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 03/10/23.
//

import DinotisData
import Foundation
import OneSignal

enum InboxType {
    case inbox
    case review
}

final class InboxViewModel: ObservableObject {
    
    private let getInboxReviewUseCase: GetInboxReviewsUseCase
    private let getInboxChatsUseCase: GetInboxChatsUseCase
    private let stateObservable = StateObservable.shared
    @Published var route: HomeRouting?
    
    @Published var isLoadingInbox = false
    @Published var isLoadingReview = false
    @Published var isError = false
    @Published var isRefreshFailed = false
    @Published var error = ""
    
    @Published var discussionChatCounter: String = ""
    @Published var completedSessionCounter: String = ""
    @Published var reviewCounter: String = ""
    
    init(getInboxReviewUseCase: GetInboxReviewsUseCase = GetInboxReviewsDefaultUseCase(), getInboxChatsUseCase: GetInboxChatsUseCase = GetInboxChatsDefaultUseCase()) {
        self.getInboxReviewUseCase = getInboxReviewUseCase
        self.getInboxChatsUseCase = getInboxChatsUseCase
    }
    
    func routeToDiscussionList(_ type: DiscussionListType) {
        let viewModel = DiscussionListViewModel(type: type)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .discussionList(viewModel: viewModel)
        }
    }
    
    func routeToReviewList() {
        let viewModel = ReviewListViewModel()
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .reviewList(viewModel: viewModel)
        }
    }
    
    func fetchStarted(isRefresh: Bool) {
        DispatchQueue.main.async { [weak self] in
            if !isRefresh {
                self?.isLoadingInbox = true
            }
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
    
    func onLoadChats(section: ChatInboxFilter, query: String, isRefresh: Bool = false) {
        Task {
            await getInboxChat(section: section, query: query, isRefresh: isRefresh)
        }
    }
    
    @MainActor
    func getInboxChat(section: ChatInboxFilter, query: String, isRefresh: Bool) async {
        fetchStarted(isRefresh: isRefresh)
        
        let result = await getInboxChatsUseCase.execute(with: section, by: query)
        
        switch result {
        case .success(let response):
            self.isLoadingInbox = false
            
            self.discussionChatCounter = response.counter ?? ""
        case .failure(let error):
            handleDefaultError(error: error, type: .inbox)
        }
    }
    
    func handleDefaultError(error: Error, type: InboxType) {
        DispatchQueue.main.async { [weak self] in
            switch type {
            case .inbox:
                self?.isLoadingInbox = false
            case .review:
                self?.isLoadingReview = false
            }
            
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
    
    func fetchStarted() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoadingReview = true
            self?.isError = false
            self?.isRefreshFailed = false
            self?.error = ""
        }
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
            self.isLoadingReview = false
            
            self.reviewCounter = response.counter ?? ""
        case .failure(let error):
            handleDefaultError(error: error, type: .review)
        }
    }
}
