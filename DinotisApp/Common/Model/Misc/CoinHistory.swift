//
//  CoinHistory.swift
//  DinotisApp
//
//  Created by Gus Adi on 21/06/22.
//

import Foundation

struct CoinQuery: Codable {
	var skip: UInt
	var take: UInt
}

struct CoinHistoryResponse: Codable {
	let data: [CoinHistoryData]?
	let nextCursor: Int?
}

struct CoinHistoryData: Codable {
	let id: Int?
	let title: String?
	let description: String?
	let amount: Int64?
	let isOut: Bool?
	let isConfirmed: Bool?
	let coinBalanceId: Int?
	let meetingId: String?
	let createdAt: String?
	let isPending: Bool?
	let isSuccess: Bool?

	static func == (lhs: CoinHistoryData, rhs: CoinHistoryData) -> Bool {
		return lhs.id.orZero() == rhs.id.orZero()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}
}
