//
//  File.swift
//  
//
//  Created by Gus Adi on 13/10/23.
//

import Foundation

public protocol GetInboxChatsUseCase {
    func execute(with filter: ChatInboxFilter, by query: String) async -> Result<InboxChatResponse, Error>
}
