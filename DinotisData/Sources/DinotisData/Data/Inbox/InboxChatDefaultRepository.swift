//
//  File.swift
//  
//
//  Created by Gus Adi on 13/10/23.
//

import Foundation

public final class InboxChatDefaultRepository: InboxChatRepository {
    
    private let remote: InboxChatRemoteDataSource
    
    public init(remote: InboxChatRemoteDataSource = InboxChatDefaultRemoteDataSource()) {
        self.remote = remote
    }
    
    public func provideGetInboxChat(with filter: ChatInboxFilter, by query: String) async throws -> InboxChatResponse {
        try await remote.getInboxChat(filter: filter, query: query)
    }
}
