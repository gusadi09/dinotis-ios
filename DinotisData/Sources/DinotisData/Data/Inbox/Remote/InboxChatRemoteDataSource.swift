//
//  File.swift
//  
//
//  Created by Gus Adi on 13/10/23.
//

import Foundation

public protocol InboxChatRemoteDataSource {
    func getInboxChat(filter: ChatInboxFilter, query: String) async throws -> InboxChatResponse
}
