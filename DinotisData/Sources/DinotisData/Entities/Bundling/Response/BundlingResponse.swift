//
//  File.swift
//  
//
//  Created by Gus Adi on 01/02/23.
//

import Foundation

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
	public let meetings: [GeneralMeetingData]?
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
		meetings: [GeneralMeetingData]?,
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
