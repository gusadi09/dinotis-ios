//
//  SubscriptionResponse.swift
//
//
//  Created by Irham Naufal on 25/11/23.
//

import Foundation

public struct SubscriptionListResponse: Codable {
    public let data: [SubscriptionResponse]?
    public let nextCursor: Int?
    
    public init(data: [SubscriptionResponse]? = nil, nextCursor: Int?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}

public struct SubscriptionResponse: Codable, Hashable {
    public let id: String?
    public let userId: String?
    public let talentId: String?
    public var subscriptionType: String?
    public let startAt: Date?
    public let endAt: Date?
    public let user: UserSubscriptionResponse?
    public let subscriptionPayment: SubscriptionPayment?
    
    public init(id: String?, userId: String?, talentId: String?, subscriptionType: String? = nil, startAt: Date?, endAt: Date?, user: UserSubscriptionResponse? = nil, subscriptionPayment: SubscriptionPayment? = nil) {
        self.id = id
        self.userId = userId
        self.talentId = talentId
        self.subscriptionType = subscriptionType
        self.startAt = startAt
        self.endAt = endAt
        self.user = user
        self.subscriptionPayment = subscriptionPayment
    }
    
    public static func == (lhs: SubscriptionResponse, rhs: SubscriptionResponse) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct UserSubscriptionResponse: Codable {
    public let id: String?
    public let name: String?
    public let username: String?
    public let profilePhoto: String?
    public let isVerified: Bool?
    
    public init(id: String? = nil, name: String? = nil, username: String? = nil, profilePhoto: String? = nil, isVerified: Bool? = nil) {
        self.id = id
        self.name = name
        self.username = username
        self.profilePhoto = profilePhoto
        self.isVerified = isVerified
    }
}

public struct SubscriptionPayment: Codable {
    public let id: String?
    public let amount: String?
    public let paymentMethod: PaymentMethodData?
    
    public init(id: String?, amount: String?, paymentMethod: PaymentMethodData?) {
        self.id = id
        self.amount = amount
        self.paymentMethod = paymentMethod
    }
}
