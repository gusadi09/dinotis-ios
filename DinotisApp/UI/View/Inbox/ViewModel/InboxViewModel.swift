//
//  InboxViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 03/10/23.
//

import Foundation

final class InboxViewModel: ObservableObject {
    
    @Published var discussionChatCounter: String = ""
    @Published var completedSessionCounter: String = ""
    @Published var reviewCounter: String = ""
}
