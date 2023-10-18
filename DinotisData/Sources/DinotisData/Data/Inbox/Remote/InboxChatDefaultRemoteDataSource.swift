//
//  File.swift
//  
//
//  Created by Gus Adi on 13/10/23.
//

import Foundation
import Moya

public final class InboxChatDefaultRemoteDataSource: InboxChatRemoteDataSource {
    
    private let provider: MoyaProvider<InboxTargetType>
    
    public init(provider: MoyaProvider<InboxTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    public func getInboxChat(filter: ChatInboxFilter, query: String) async throws -> InboxChatResponse {
        try await provider.request(.getInboxChat(filter, query), model: InboxChatResponse.self)
    }
}
