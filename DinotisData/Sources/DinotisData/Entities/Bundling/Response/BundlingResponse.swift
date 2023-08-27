//
//  File.swift
//  
//
//  Created by Gus Adi on 01/02/23.
//

import Foundation

public struct BundlingListResponse: Codable {
    public let data: [BundlingData]?
    public let filters: FilterBundlingData?
    public let nextCursor: Int?
    
    public init(
        data: [BundlingData]?,
        filters: FilterBundlingData?,
        nextCursor: Int?
    ) {
        self.data = data
        self.filters = filters
        self.nextCursor = nextCursor
    }
}

public struct BundlingData: Codable, Hashable {
	public static func == (lhs: BundlingData, rhs: BundlingData) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	public let id: String?
	public let title: String?
	public let description: String?
	public let price: String?
	public let createdAt: Date?
	public let updatedAt: Date?
	public let isActive: Bool?
	public let session: Int?
	public let isBundling: Bool?
	public let isAlreadyBooked: Bool?
	public let isFailed: Bool?
	public let user: UserResponse?
	public let meetings: [MeetingDetailResponse]?
	public let meetingBundleId: String?
	public let background: [String]?

	public init(
		id: String?,
		title: String?,
		description: String?,
		price: String?,
		createdAt: Date?,
		updatedAt: Date?,
		isActive: Bool?,
		session: Int?,
		isBundling: Bool?,
		isAlreadyBooked: Bool?,
		isFailed: Bool?,
		user: UserResponse?,
		meetings: [MeetingDetailResponse]?,
		meetingBundleId: String?,
		background: [String]?
	) {
		self.id = id
		self.title = title
		self.description = description
		self.price = price
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.isActive = isActive
		self.session = session
		self.isBundling = isBundling
		self.isAlreadyBooked = isAlreadyBooked
		self.isFailed = isFailed
		self.user = user
		self.meetings = meetings
		self.meetingBundleId = meetingBundleId
		self.background = background
	}
}

public struct FilterBundlingData: Codable {
    public let options: [BundlingFilterOptions]?
    
    public init(options: [BundlingFilterOptions]?) {
        self.options = options
    }
}

public struct BundlingFilterOptions: Codable, Identifiable {
    public let id = UUID()
    public let queries: [BundlingFilterOptionQuery]?
    public let label: String?
    
    public init(
        queries: [BundlingFilterOptionQuery]?,
        label: String?
    ) {
        self.queries = queries
        self.label = label
    }
}

public struct BundlingFilterOptionQuery: Codable, Identifiable {
    public let id = UUID()
    public let name: String?
    public let value: String?
    
    public init(name: String?, value: String?) {
        self.name = name
        self.value = value
    }
}

public struct DetailBundlingResponse: Codable {
    public let id: String?
    public let title: String?
    public let description: String?
    public let price: String?
    public let user: UserResponse?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let meetings: [MeetingDetailResponse]?
    
    public init(
        id: String?,
        title: String?,
        description: String?,
        price: String?,
        user: UserResponse?,
        createdAt: Date?,
        updatedAt: Date?,
        meetings: [MeetingDetailResponse]?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.user = user
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.meetings = meetings
    }
}

public struct CreateBundlingResponse: Codable {
    public let id: String?
    public let title: String?
    public let description: String?
    public let price: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(
        id: String?,
        title: String?,
        description: String?,
        price: String?,
        createdAt: Date?,
        updatedAt: Date?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct AvailableMeetingResponse: Codable {
    public let data: [MeetingDetailResponse]?
    
    public init(data: [MeetingDetailResponse]?) {
        self.data = data
    }
}
