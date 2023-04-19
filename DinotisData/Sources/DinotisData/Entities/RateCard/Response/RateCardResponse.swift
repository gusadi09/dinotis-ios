//
//  File.swift
//  
//
//  Created by Gus Adi on 22/02/23.
//

import Foundation

public struct RateCardResponse: Codable, Hashable {
	public let id: String?
	public let title: String?
	public let description: String?
	public let price: String?
	public let duration: Int?
	public let isPrivate: Bool?

	public static func == (lhs: RateCardResponse, rhs: RateCardResponse) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id.orEmpty())
	}

	public init(id: String?, title: String?, description: String?, price: String?, duration: Int?, isPrivate: Bool?) {
		self.id = id
		self.title = title
		self.description = description
		self.price = price
		self.duration = duration
		self.isPrivate = isPrivate
	}
}

public struct RateCardListResponse: Codable {
	public let data: [RateCardResponse]?
	public let nextCursor: Int?

	public init(data: [RateCardResponse]?, nextCursor: Int?) {
		self.data = data
		self.nextCursor = nextCursor
	}
}

public struct MeetingRequestsResponse: Codable {
	public let data: [MeetingRequestData]?
	public let filters: FilterOptionMeetingRequest?
	public let cancelOptions: [CancelOptionData]?
	public let counter: String?
	public let nextCursor: Int?

	public init(data: [MeetingRequestData]?, filters: FilterOptionMeetingRequest?, cancelOptions: [CancelOptionData]?, counter: String?, nextCursor: Int?) {
		self.data = data
		self.filters = filters
		self.cancelOptions = cancelOptions
		self.counter = counter
		self.nextCursor = nextCursor
	}
}

public struct FilterOptionMeetingRequest: Codable {
	public let options: [OptionMeetingRequestData]?

	public init(options: [OptionMeetingRequestData]?) {
		self.options = options
	}
}

public struct OptionMeetingRequestData: Codable {
	public let id = UUID()
	public let queries: [QueryMeetingRequestData]?
	public let label: String?

	public init(queries: [QueryMeetingRequestData]?, label: String?) {
		self.queries = queries
		self.label = label
	}
}

public struct QueryMeetingRequestData: Codable {
	public let name: String?
	public let value: String?

	public init(name: String?, value: String?) {
		self.name = name
		self.value = value
	}
}

public struct CancelOptionData: Codable, Hashable {
	public let id: Int?
	public let name: String?

	public static func == (lhs: CancelOptionData, rhs: CancelOptionData) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}

	public init(id: Int?, name: String?) {
		self.id = id
		self.name = name
	}
}

public struct CustomerChatTokenResponse: Codable {
	public let token: String?

	public init(token: String?) {
		self.token = token
	}
}
