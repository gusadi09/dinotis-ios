//
//  File.swift
//  
//
//  Created by Gus Adi on 26/02/23.
//

import Foundation

public protocol ConversationTokenUseCase {
	func execute(with id: String) async -> Result<CustomerChatTokenResponse, Error>
}
