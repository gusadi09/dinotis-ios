//
//  CustomerChatManager.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/11/22.
//

import TwilioConversationsClient

struct GroupedChat: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    let date: Date
    let chat: [CustomerChatMessage]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class CustomerChatManager: NSObject, ObservableObject {
	@Published var hasUnreadMessage = false
	@Published var unreadChatCount = 0
	@Published var messages: [CustomerChatMessage] = []
    @Published var groupedMessage: [GroupedChat] = []
    
    @Published var isLoading = false
    @Published var isLoadingMore = false
	var isConnected: Bool { client != nil }
	private var client: TwilioConversationsClient?
	private var conversation: TCHConversation?
	private var conversationName = ""

	init(messages: [CustomerChatMessage] = []) {
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
        groupedMessage = []
		hasUnreadMessage = false
	}

	func sendMessage(_ message: String) {
		conversation?.prepareMessage().setBody(message).buildAndSend(completion: nil)
	}

	private func getConversation(isMore: Bool) {
		client?.conversation(withSidOrUniqueName: conversationName) { [weak self] _, conversation in
			self?.conversation = conversation
            self?.getMessages(isMore: isMore)
		}
	}

    func getMessages(count: UInt = 100, isMore: Bool) {
        if isMore {
            isLoadingMore = true
        } else {
            isLoading = true
        }
		/// Just get the last 100 messages since the UI does not have pagination in this app
		conversation?.getLastMessages(withCount: count) { [weak self] _, messages in
			guard let messages = messages else {
				return
			}

			self?.messages = messages.compactMap { CustomerChatMessage(message: $0, conversation: self?.conversation) }
            let temp = messages.compactMap { CustomerChatMessage(message: $0, conversation: self?.conversation) }
            self?.groupedMessage = (self?.mapTo2DArray(elements: temp) ?? []).compactMap({
                GroupedChat(date: ($0.first?.date).orCurrentDate(), chat: $0)
            })
            
			if !messages.isEmpty {
				self?.hasUnreadMessage = true
			}
            
            if isMore {
                self?.isLoadingMore = false
            } else {
                self?.isLoading = false
            }
		}
	}
    
    func mapTo2DArray(elements: [CustomerChatMessage]) -> [[CustomerChatMessage]] {
        let groupedElements = Dictionary(grouping: elements) { element in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"  // Format the date as needed
            return dateFormatter.string(from: element.date)
        }
        
        return groupedElements.compactMap { (_, elementsForDate) in
            guard !elementsForDate.isEmpty else { return nil }
            return elementsForDate
        }
    }
}

extension CustomerChatManager: TwilioConversationsClientDelegate {
	func conversationsClient(
		_ client: TwilioConversationsClient,
		synchronizationStatusUpdated status: TCHClientSynchronizationStatus
	) {
		switch status {
		case .started, .conversationsListCompleted:
            isLoading = true
			return
		case .completed:
            getConversation(isMore: false)
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
		guard conversation.sid == self.conversation?.sid, let message = CustomerChatMessage(message: message, conversation: conversation) else {
			return
		}

		messages.append(message)
        
        self.groupedMessage = self.mapTo2DArray(elements: messages).compactMap({
            GroupedChat(date: ($0.first?.date).orCurrentDate(), chat: $0)
        })
		hasUnreadMessage = true
	}
}
