//
//  File.swift
//  
//
//  Created by Gus Adi on 27/02/23.
//

import Foundation

public struct CoinHistoryResponse: Codable {
	public let data: [CoinHistoryData]?
	public let nextCursor: Int?

	public init(data: [CoinHistoryData]?, nextCursor: Int?) {
		self.data = data
		self.nextCursor = nextCursor
	}
}

public struct CoinHistoryData: Codable {
	public let id: Int?
	public let title: String?
	public let description: String?
	public let amount: Int64?
	public let isOut: Bool?
	public let isConfirmed: Bool?
	public let coinBalanceId: Int?
	public let meetingId: String?
	public let createdAt: Date?
	public let isPending: Bool?
	public let isSuccess: Bool?

	public static func == (lhs: CoinHistoryData, rhs: CoinHistoryData) -> Bool {
		return lhs.id.orZero() == rhs.id.orZero()
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}

	public init(id: Int?, title: String?, description: String?, amount: Int64?, isOut: Bool?, isConfirmed: Bool?, coinBalanceId: Int?, meetingId: String?, createdAt: Date?, isPending: Bool?, isSuccess: Bool?) {
		self.id = id
		self.title = title
		self.description = description
		self.amount = amount
		self.isOut = isOut
		self.isConfirmed = isConfirmed
		self.coinBalanceId = coinBalanceId
		self.meetingId = meetingId
		self.createdAt = createdAt
		self.isPending = isPending
		self.isSuccess = isSuccess
	}
}
