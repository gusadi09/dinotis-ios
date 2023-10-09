//
//  DiscussionListViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 04/10/23.
//

import DinotisDesignSystem
import Foundation

enum DiscussionFilter {
    case latest
    case earliest
    case unread
    case nearest
}

enum DiscussionListType {
    case ongoing
    case completed
}

enum SearchState {
    case initiate
    case success
    case empty
}

struct DummyDiscussion: Identifiable {
    var id: UUID = .init()
    var title: String
    var hasAccepted: Bool
    var expiredAt: Date
    var hasRead: Bool
    var name: String
    var profilePicture: String
    var message: String
    var date: Date
}

final class DiscussionListViewModel: ObservableObject {
    
    @Published var type: DiscussionListType
    
    var tabSections: [DiscussionFilter] {
        switch type {
        case .ongoing:
            return [.latest, .earliest, .unread, .nearest]
        case .completed:
            return [.latest, .earliest]
        }
    }
    @Published var currentSection: DiscussionFilter = .latest
    
    @Published var isSearching = false
    @Published var searchText = ""
    
    @Published var data: [DummyDiscussion] = [
        .init(title: "This is Title One",
              hasAccepted: .random(),
              expiredAt: .now + 100000,
              hasRead: .random(),
              name: "Zee JKT48",
              profilePicture: "https://media.kompas.tv/library/image/content_article/article_img/20220926073750.jpg",
              message: "Hello! would love to discuss our upcoming for the next season",
              date: .now),
        .init(title: "This is Title Second",
              hasAccepted: .random(),
              expiredAt: .now + 100000,
              hasRead: .random(),
              name: "Zee JKT48",
              profilePicture: "https://media.kompas.tv/library/image/content_article/article_img/20220926073750.jpg",
              message: "Hello! would love to discuss our upcoming for the next season",
              date: .now),
        .init(title: "This is Title Third",
              hasAccepted: .random(),
              expiredAt: .now + 100000,
              hasRead: .random(),
              name: "Zee JKT48",
              profilePicture: "https://media.kompas.tv/library/image/content_article/article_img/20220926073750.jpg",
              message: "Hello! would love to discuss our upcoming for the next season",
              date: .now),
        .init(title: "This is Title Fourth",
              hasAccepted: .random(),
              expiredAt: .now + 100000,
              hasRead: .random(),
              name: "Zee JKT48",
              profilePicture: "https://media.kompas.tv/library/image/content_article/article_img/20220926073750.jpg",
              message: "Hello! would love to discuss our upcoming for the next season",
              date: .now),
        .init(title: "This is Title Fifth",
              hasAccepted: .random(),
              expiredAt: .now + 100000,
              hasRead: .random(),
              name: "Zee JKT48",
              profilePicture: "https://media.kompas.tv/library/image/content_article/article_img/20220926073750.jpg",
              message: "Hello! would love to discuss our upcoming for the next season",
              date: .now),
        
    ]
    
    var searchedData: [DummyDiscussion] {
        return data.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }
    
    var searchState: SearchState {
        if !searchText.isEmpty && searchedData.isEmpty {
            return .empty
        } else if !searchText.isEmpty && !searchedData.isEmpty {
            return .success
        } else {
            return .initiate
        }
    }
    
    init(type: DiscussionListType) {
        self.type = type
    }
}
