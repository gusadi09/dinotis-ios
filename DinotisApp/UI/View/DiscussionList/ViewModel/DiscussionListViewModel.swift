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
    
    init(type: DiscussionListType) {
        self.type = type
    }
}
