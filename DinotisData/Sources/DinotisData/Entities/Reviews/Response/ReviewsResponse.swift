//
//  File.swift
//  
//
//  Created by Gus Adi on 03/02/23.
//

import Foundation

public struct ReviewsResponse: Codable {
	public let data: [ReviewData]?
	public let nextCursor: Int?

	public init(data: [ReviewData]?, nextCursor: Int?) {
		self.data = data
		self.nextCursor = nextCursor
	}
}

public extension ReviewsResponse {
	static var sample: ReviewsResponse {
		ReviewsResponse(data: [ReviewData.sample], nextCursor: 0)
	}

	static var sampleData: Data {
		ReviewsResponse(data: [ReviewData.sample], nextCursor: 0).toJSONData()
	}
}

public struct ReviewData: Codable, Hashable {
	public static func == (lhs: ReviewData, rhs: ReviewData) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	public let id: Int?
	public let rating: String?
	public let review: String?
	public let userId: String?
	public let meetingId: String?
	public let talentId: String?
	public let createdAt: Date?
	public let updatedAt: Date?
	public let user: UserReviewData?

	public init(
		id: Int?,
		rating: String?,
		review: String?,
		userId: String?,
		meetingId: String?,
		talentId: String?,
		createdAt: Date?,
		updatedAt: Date?,
		user: UserReviewData?
	) {
		self.id = id
		self.rating = rating
		self.review = review
		self.userId = userId
		self.meetingId = meetingId
		self.talentId = talentId
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.user = user
	}
}

public struct ReviewSuccessResponse: Codable, Hashable {
    public static func == (lhs: ReviewSuccessResponse, rhs: ReviewSuccessResponse) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public let id: Int?
    public let rating: Int?
    public let review: String?
    public let userId: String?
    public let talentId: String?
    public let meetingId: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let tip: Int?

    public init(
        id: Int?,
        rating: Int?,
        review: String?,
        userId: String?,
        talentId: String?,
        meetingId: String?,
        createdAt: Date?,
        updatedAt: Date?,
        tip: Int?
    ) {
        self.id = id
        self.rating = rating
        self.review = review
        self.userId = userId
        self.talentId = talentId
        self.meetingId = meetingId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tip = tip
    }
}

public struct UserReviewData: Codable {
	public let id: String?
	public let name: String?
	public let profilePhoto: String?

	public init(id: String?, name: String?, profilePhoto: String?) {
		self.id = id
		self.name = name
		self.profilePhoto = profilePhoto
	}
}

public extension ReviewSuccessResponse {
    static var sample: ReviewSuccessResponse {
        ReviewSuccessResponse(
            id: 1,
            rating: 4,
            review: "",
            userId: "userunittest",
            talentId: "talentunittest",
            meetingId: "meetingunittest",
            createdAt: Date(),
            updatedAt: Date(),
            tip: 1000
        )
    }
    
    static var sampleData: Data {
        ReviewSuccessResponse(
            id: 1,
            rating: 4,
            review: "",
            userId: "userunittest",
            talentId: "talentunittest",
            meetingId: "meetingunittest",
            createdAt: Date(),
            updatedAt: Date(),
            tip: 1000
        )
        .toJSONData()
    }
}

public extension ReviewData {
	static var sample: ReviewData {
		ReviewData(
			id: 1,
			rating: "4.5",
			review: "Ini review dari unit test",
			userId: "unittestuser",
			meetingId: "unittestmeeting",
			talentId: "unittesttalent",
			createdAt: Date(),
			updatedAt: Date(),
			user: UserReviewData.sample
		)
	}

	static var sampleData: Data {
		ReviewData(
			id: 1,
			rating: "4.5",
			review: "Ini review dari unit test",
			userId: "unittestuser",
			meetingId: "unittestmeeting",
			talentId: "unittesttalent",
			createdAt: Date(),
			updatedAt: Date(),
			user: UserReviewData.sample
		)
		.toJSONData()
	}
}

public extension UserReviewData {
	static var sample: UserReviewData {
		UserReviewData(id: "unittestid", name: "Unit Test", profilePhoto: "https://www.unittest.com/abcde.png")
	}

	static var sampleData: Data {
		UserReviewData(id: "unittestid", name: "Unit Test", profilePhoto: "https://www.unittest.com/abcde.png").toJSONData()
	}
}

public struct ReviewReasons: Codable {
    public let data: [String]?
    
    public init(data: [String]?) {
        self.data = data
    }
}

public struct TipAmounts: Codable {
    public let data: [Amount]?
    
    public init(data: [Amount]?) {
        self.data = data
    }
}

public struct Amount: Codable {
    public let amount: Int?
    
    public init(amount: Int?) {
        self.amount = amount
    }
}
