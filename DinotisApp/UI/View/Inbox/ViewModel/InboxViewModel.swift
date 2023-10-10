//
//  InboxViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 03/10/23.
//

import Foundation

final class InboxViewModel: ObservableObject {
    
    @Published var route: HomeRouting?
    
    @Published var discussionChatCounter: String = ""
    @Published var completedSessionCounter: String = ""
    @Published var reviewCounter: String = ""
    
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
}
