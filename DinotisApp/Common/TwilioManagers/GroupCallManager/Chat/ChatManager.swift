//
//  ChatManager.swift
//  DinotisApp
//
//  Created by Garry on 05/08/22.
//

import TwilioConversationsClient

class ChatManager: NSObject, ObservableObject {
	@Published var hasUnreadMessage = false
	@Published var messages: [ChatMessage] = []
	var isConnected: Bool { client != nil }
	private var client: TwilioConversationsClient?
	private var conversation: TCHConversation?
	private var conversationName = ""
	
	init(messages: [ChatMessage] = []) {
		self.messages = messages
	}
	
	func connect(accessToken: String, conversationName: String) {
		self.conversationName = conversationName
		
		let properties = TwilioConversationsClientProperties()
		
		TwilioConversationsClient.conversationsClient(
			withToken: accessToken,
			properties: properties,
			delegate: self
		) { _, client in
			self.client = client
		}
	}
	
	func disconnect() {
		client?.shutdown()
		client = nil
		conversation = nil
		messages = []
		hasUnreadMessage = false
	}
	
	func sendMessage(_ message: String) {
		conversation?.prepareMessage().setBody(message).buildAndSend(completion: nil)
	}
	
	private func getConversation() {
		client?.conversation(withSidOrUniqueName: conversationName) { [weak self] _, conversation in
			self?.conversation = conversation
			self?.getMessages()
		}
	}
	
	func getMessages() {
		/// Just get the last 100 messages since the UI does not have pagination in this app
		conversation?.getLastMessages(withCount: 100000) { [weak self] _, messages in
			guard let messages = messages else {
				return
			}
			
			self?.messages = messages.compactMap { ChatMessage(message: $0) }
			
			if !messages.isEmpty {
				self?.hasUnreadMessage = true
			}
		}
	}
}

extension ChatManager: TwilioConversationsClientDelegate {
	func conversationsClient(
		_ client: TwilioConversationsClient,
		synchronizationStatusUpdated status: TCHClientSynchronizationStatus
	) {
		switch status {
		case .started, .conversationsListCompleted:
			return
		case .completed:
			getConversation()
		case .failed:
			disconnect()
		@unknown default:
			return
		}
	}
	
	func conversationsClient(
		_ client: TwilioConversationsClient,
		conversation: TCHConversation,
		messageAdded message: TCHMessage
	) {
		guard conversation.sid == self.conversation?.sid, let message = ChatMessage(message: message) else {
			return
		}
		
		messages.append(message)
		hasUnreadMessage = true
	}
}
