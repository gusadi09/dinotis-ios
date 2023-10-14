//
//  File.swift
//  
//
//  Created by Gus Adi on 13/10/23.
//

import Foundation

public protocol InboxChatRepository {
    func provideGetInboxChat(with filter: ChatInboxFilter, by query: String) async throws -> InboxChatResponse
}
