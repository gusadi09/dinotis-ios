//
//  File.swift
//  
//
//  Created by Gus Adi on 22/02/23.
//

import Foundation

public struct RateCardFilterRequest: Codable {
	public var take: Int
	public var skip: Int
	public var isAccepted: String
	public var isNotConfirmed: String

	public init(take: Int = 15, skip: Int = 0, isAccepted: String = "", isNotConfirmed: String = "true") {
		self.take = take
		self.skip = skip
		self.isAccepted = isAccepted
		self.isNotConfirmed = isNotConfirmed
	}
}

public struct ConfirmationRateCardRequest: Codable {
	public var isAccepted: Bool
	public var reasons: [Int]?
	public var otherReason: String?

	public init(isAccepted: Bool, reasons: [Int]? = nil, otherReason: String? = nil) {
		self.isAccepted = isAccepted
		self.reasons = reasons
		self.otherReason = otherReason
	}
}

public struct RequestSessionRequest: Codable {
	public var paymentMethod: Int?
	public var rateCardId: String
	public var message: String?
	public var voucherCode: String?
    public var requestAt: String?

    public init(paymentMethod: Int? = nil, rateCardId: String, message: String?, voucherCode: String? = nil, requestAt: String?) {
		self.paymentMethod = paymentMethod
		self.rateCardId = rateCardId
		self.message = message
		self.voucherCode = voucherCode
        self.requestAt = requestAt
	}
}

public struct CreateRateCardRequest: Codable {
	public let title: String
	public let description: String
	public let duration: Int
	public let price: Int

	public init(title: String, description: String, duration: Int, price: Int) {
		self.title = title
		self.description = description
		self.duration = duration
		self.price = price
	}
}

public struct EditRequestedSessionRequest: Codable {
	public let startAt: String
	public let endAt: String

	public init(startAt: String, endAt: String) {
		self.startAt = startAt
		self.endAt = endAt
	}
}

public struct SendScheduleRequest: Codable {
    public let requestUserId: String
    public let type: String
    public let message: String
    
    public init(requestUserId: String, type: String, message: String) {
        self.requestUserId = requestUserId
        self.type = type
        self.message = message
    }
}
