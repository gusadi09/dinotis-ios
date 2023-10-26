//
//  File.swift
//  
//
//  Created by Gus Adi on 13/10/23.
//

import Foundation

public struct InboxData: Codable, Hashable {
    public let id: String?
    public let conversationSid: String?
    public let meetingRequestId: String?
    public let user: UserResponse?
    public let meeting: MeetingDetailResponse?
    public let status: String?
    public let sendAt: Date?
    public let lastMessage: String?
    public let expiredAt: Date?
    
    public init(id: String?, conversationSid: String?, meetingRequestId: String?, user: UserResponse?, meeting: MeetingDetailResponse?, status: String?, sendAt: Date?, lastMessage: String?, expiredAt: Date?) {
        self.id = id
        self.conversationSid = conversationSid
        self.meetingRequestId = meetingRequestId
        self.user = user
        self.meeting = meeting
        self.status = status
        self.sendAt = sendAt
        self.lastMessage = lastMessage
        self.expiredAt = expiredAt
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public extension InboxData {
    static var sample: InboxData {
        InboxData(
            id: "testing",
            conversationSid: "testing",
            meetingRequestId: "testing",
            user: .sample,
            meeting: nil,
            status: "testing",
            sendAt: Date(),
            lastMessage: "testing",
            expiredAt: Date()
        )
    }
    
    static var sampleData: Data {
        InboxData(
            id: "testing",
            conversationSid: "testing",
            meetingRequestId: "testing",
            user: .sample,
            meeting: nil,
            status: "testing",
            sendAt: Date(),
            lastMessage: "testing",
            expiredAt: Date()
        ).toJSONData()
    }
}

public struct InboxChatResponse: Codable {
    public let data: [InboxData]?
    public let counter: String?
    
    public init(data: [InboxData]?, counter: String?) {
        self.data = data
        self.counter = counter
    }
}

public extension InboxChatResponse {
    static var sample: InboxChatResponse {
        InboxChatResponse(data: [.sample], counter: "1")
    }
    
    static var sampleData: Data {
        InboxChatResponse(data: [.sample], counter: "1").toJSONData()
    }
}
