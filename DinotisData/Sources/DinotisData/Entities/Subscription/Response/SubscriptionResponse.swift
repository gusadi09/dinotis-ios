//
//  SubscriptionResponse.swift
//
//
//  Created by Irham Naufal on 25/11/23.
//

import Foundation

public struct SubscriptionResponse: Codable {
    public let id: String?
    public let userId: String?
    public let talentId: String?
    public var subscriptionType: String?
    public let startAt: Date?
    public let endAt: Date?
    
    public init(id: String?, userId: String?, talentId: String?, subscriptionType: String? = nil, startAt: Date?, endAt: Date?) {
        self.id = id
        self.userId = userId
        self.talentId = talentId
        self.subscriptionType = subscriptionType
        self.startAt = startAt
        self.endAt = endAt
    }
}
