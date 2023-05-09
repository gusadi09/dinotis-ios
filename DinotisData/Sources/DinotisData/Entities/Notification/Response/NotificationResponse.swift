//
//  File.swift
//  
//
//  Created by Gus Adi on 03/03/23.
//

import Foundation

public struct NotificationData: Codable, Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.orEmpty())
    }
    
    public let id: String?
    public let thumbnail: String?
    public let type: String?
    public let status: String?
    public let message: String?
    public let description: String?
    public let iosUrl: String?
    public let url: String?
    public let userId: String?
    public let createdAt: Date?
    public let readAt: Date?
    public let language: String?
    public let meetingId: String?
    
    public init(id: String?, thumbnail: String?, type: String?, status: String?, message: String?, description: String?, iosUrl: String?, url: String?, userId: String?, createdAt: Date?, readAt: Date?, language: String?, meetingId: String?) {
        self.id = id
        self.thumbnail = thumbnail
        self.type = type
        self.status = status
        self.message = message
        self.description = description
        self.iosUrl = iosUrl
        self.url = url
        self.userId = userId
        self.createdAt = createdAt
        self.readAt = readAt
        self.language = language
        self.meetingId = meetingId
    }
}

public struct NotificationResponse: Codable {
    public let data: [NotificationData?]?
    public let nextCursor: Int?
    
    public init(data: [NotificationData?]?, nextCursor: Int?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}
