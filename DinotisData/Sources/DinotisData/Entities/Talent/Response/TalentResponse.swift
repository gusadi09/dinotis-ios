//
//  File.swift
//  
//
//  Created by Gus Adi on 02/02/23.
//

import Foundation

public struct TrendingTalent: Codable {
	public let id: String?
	public let createdAt: Date?
	public let updatedAt: Date?
	public let talentId: String?
	public let updatedById: String?
	public let talent: TalentData?

	public init(
		id: String?,
		createdAt: Date?,
		updatedAt: Date?,
		talentId: String?,
		updatedById: String?,
		talent: TalentData?
	) {
		self.id = id
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.talentId = talentId
		self.updatedById = updatedById
		self.talent = talent
	}
}

public struct TalentData: Codable, Hashable {
	public static func == (lhs: TalentData, rhs: TalentData) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	public let id: String?
	public let name: String?
	public let username: String?
	public let email: String?
	public let profilePhoto: String?
	public let profileDescription: String?
	public let emailVerifiedAt: Date?
	public let isVerified: Bool?
    public let professions: [ProfessionData]?
    public let stringProfessions: [String]?

	public init(
		id: String?,
		name: String?,
		username: String?,
		email: String?,
		profilePhoto: String?,
		profileDescription: String?,
		emailVerifiedAt: Date?,
		isVerified: Bool?,
        professions: [ProfessionData]?,
        stringProfessions: [String]?
	) {
		self.id = id
		self.name = name
		self.username = username
		self.email = email
		self.profilePhoto = profilePhoto
		self.profileDescription = profileDescription
		self.emailVerifiedAt = emailVerifiedAt
		self.isVerified = isVerified
		self.professions = professions
        self.stringProfessions = stringProfessions
	}
}

public struct TalentWithProfessionData: Codable, Hashable {
	public static func == (lhs: TalentWithProfessionData, rhs: TalentWithProfessionData) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	public let id: String?
	public let name: String?
	public let username: String?
	public let email: String?
	public let profilePhoto: String?
	public let profileDescription: String?
	public let emailVerifiedAt: Date?
	public let isVerified: Bool?
	public let professions: [ProfessionData]?
	public let rating: String?
	public let meetingCount: Int?

	public init(
		id: String?,
		name: String?,
		username: String?,
		email: String?,
		profilePhoto: String?,
		profileDescription: String?,
		emailVerifiedAt: Date?,
		isVerified: Bool?,
		professions: [ProfessionData]?,
		rating: String?,
		meetingCount: Int?
	) {
		self.id = id
		self.name = name
		self.username = username
		self.email = email
		self.profilePhoto = profilePhoto
		self.profileDescription = profileDescription
		self.emailVerifiedAt = emailVerifiedAt
		self.isVerified = isVerified
		self.professions = professions
		self.rating = rating
		self.meetingCount = meetingCount
	}
}

public typealias TrendingResponse = [TrendingTalent]
