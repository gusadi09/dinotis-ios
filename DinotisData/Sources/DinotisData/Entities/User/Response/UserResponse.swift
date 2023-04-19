//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public struct UserResponse: Codable, Hashable {
    public static func == (lhs: UserResponse, rhs: UserResponse) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
	public let coinBalance: CoinBalanceData?
	public let createdAt: Date?
	public let email: String?
	public let emailVerifiedAt: Date?
	public let id: String?
	public let isActive: Bool?
	public let isPasswordFilled: Bool?
	public let isVerified: Bool?
	public let isVisible: Bool?
	public let lastLoginAt: Date?
	public let name: String?
    public let username: String?
	public let phone: String?
	public let platform: String?
	public let profession: ProfessionData?
	public let professionId: Int?
	public let professions: [ProfessionData]?
    public let stringProfessions: [String]?
	public let profileDescription: String?
	public let profilePhoto: String?
	public let registeredWith: Int?
	public let roles: [RoleData]?
	public let updatedAt: Date?
	public let userHighlights: [HighlightData]?
	public let management: UserManagementData?
	public let managements: [ManagementWrappedData]?
    public let meetingCount: Int?
    public let followerCount: Int?
    public let rating: String?

	public init(
		coinBalance: CoinBalanceData?,
		createdAt: Date?,
		email: String?,
		emailVerifiedAt: Date?,
		id: String?,
		isActive: Bool?,
		isPasswordFilled: Bool?,
		isVerified: Bool?,
		isVisible: Bool?,
		lastLoginAt: Date?,
		name: String?,
        username: String?,
		phone: String?,
		platform: String?,
		profession: ProfessionData?,
		professionId: Int?,
		professions: [ProfessionData]?,
        stringProfessions: [String]?,
		profileDescription: String?,
		profilePhoto: String?,
		registeredWith: Int?,
		roles: [RoleData]?,
		updatedAt: Date?,
		userHighlights: [HighlightData]?,
		management: UserManagementData?,
		managements: [ManagementWrappedData]?,
        meetingCount: Int?,
        followerCount: Int?,
        rating: String?
	) {
		self.coinBalance = coinBalance
		self.createdAt = createdAt
		self.email = email
		self.emailVerifiedAt = emailVerifiedAt
		self.id = id
		self.isActive = isActive
		self.isPasswordFilled = isPasswordFilled
		self.isVerified = isVerified
		self.isVisible = isVisible
		self.lastLoginAt = lastLoginAt
		self.name = name
        self.username = username
		self.phone = phone
		self.platform = platform
		self.profession = profession
		self.professionId = professionId
		self.professions = professions
        self.stringProfessions = stringProfessions
		self.profileDescription = profileDescription
		self.profilePhoto = profilePhoto
		self.registeredWith = registeredWith
		self.roles = roles
		self.updatedAt = updatedAt
		self.userHighlights = userHighlights
		self.management = management
		self.managements = managements
        self.meetingCount = meetingCount
        self.followerCount =  followerCount
        self.rating = rating
	}
}

public struct UsernameAvailabilityResponse: Codable {
    public let username: String?
    
    public init(username: String?) {
        self.username = username
    }
}

public extension UserResponse {
	static var sample: UserResponse {
		UserResponse(
			coinBalance: CoinBalanceData(
				current: "10000",
				id: 1,
				updatedAt: Date(),
				userId: "Test"
			),
			createdAt: Date(),
			email: "test@test.com",
			emailVerifiedAt: Date(),
			id: "Test",
			isActive: true,
			isPasswordFilled: true,
			isVerified: true,
			isVisible: true,
			lastLoginAt: Date(),
			name: "Test",
            username: "Test",
			phone: "+62121121001",
			platform: "IOS",
			profession: ProfessionData(
				userId: "Test",
				professionId: 1,
				createdAt: Date(),
				updatedAt: Date(),
				profession: ProfessionElement(
					id: 1,
					professionCategoryId: 1,
					name: "Tester",
					createdAt: Date(),
					updatedAt: Date()
				)
			),
			professionId: 1,
			professions: [],
            stringProfessions: [],
			profileDescription: "Test",
            profilePhoto: "https://www.test.com/jsndkasdnskd.jpg",
            registeredWith: 1,
            roles: [
                RoleData(
                    userId: "Test",
                    roleId: 2,
                    createdAt: Date(),
                    updatedAt: Date(),
                    role: RoleElement(
                        id: 1,
                        name: "Talent"
                    )
                )
            ],
            updatedAt: Date(),
            userHighlights: [],
			management: UserManagementData(
				id: 1,
				code: "TST",
				userId: "Test",
				createdAt: Date(),
				updatedAt: Date(),
				managementTalents: []
			),
			managements: nil,
            meetingCount: 1,
            followerCount: 1,
            rating: "5"
		)
	}

	static var sampleData: Data {
		UserResponse(
			coinBalance: CoinBalanceData(
				current: "10000",
				id: 1,
				updatedAt: Date(),
				userId: "Test"
			),
			createdAt: Date(),
			email: "test@test.com",
			emailVerifiedAt: Date(),
			id: "Test",
			isActive: true,
			isPasswordFilled: true,
			isVerified: true,
			isVisible: true,
			lastLoginAt: Date(),
			name: "Test",
            username: "Test",
			phone: "+62121121001",
			platform: "IOS",
			profession: ProfessionData(
				userId: "Test",
				professionId: 1,
				createdAt: Date(),
				updatedAt: Date(),
				profession: ProfessionElement(
					id: 1,
					professionCategoryId: 1,
					name: "Tester",
					createdAt: Date(),
					updatedAt: Date()
				)
			),
			professionId: 1,
			professions: [],
            stringProfessions: [],
			profileDescription: "Test",
			profilePhoto: "https://www.test.com/jsndkasdnskd.jpg",
			registeredWith: 1,
			roles: [
                RoleData(
                    userId: "Test",
                    roleId: 2,
                    createdAt: Date(),
                    updatedAt: Date(),
                    role: RoleElement(
                        id: 1,
                        name: "Talent"
                    )
                )
            ],
			updatedAt: Date(),
			userHighlights: [],
			management: UserManagementData(
				id: 1,
				code: "TST",
				userId: "Test",
				createdAt: Date(),
				updatedAt: Date(),
				managementTalents: []
			),
			managements: nil,
            meetingCount: 1,
            followerCount: 1,
            rating: "5"
		).toJSONData()
	}
}

public struct CoinBalanceData: Codable {
	public let current: String?
	public let id: Int?
	public let updatedAt: Date?
	public let userId: String?

	public init(current: String?, id: Int?, updatedAt: Date?, userId: String?) {
		self.current = current
		self.id = id
		self.updatedAt = updatedAt
		self.userId = userId
	}
}

public struct ProfessionData: Codable, Equatable {

	public let userId: String?
	public let professionId: Int?
	public let createdAt, updatedAt: Date?
	public let profession: ProfessionElement?

	public static func == (lhs: ProfessionData, rhs: ProfessionData) -> Bool {
		return lhs.profession?.id == rhs.profession?.id
	}

	public init(userId: String?, professionId: Int?, createdAt: Date?, updatedAt: Date?, profession: ProfessionElement?) {
		self.userId = userId
		self.professionId = professionId
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.profession = profession
	}
}

public struct ProfessionElement: Codable, Hashable {
	public let id: Int?
	public let professionCategoryId: Int?
	public let name: String?
	public let createdAt, updatedAt: Date?

	public init(id: Int?, professionCategoryId: Int?, name: String?, createdAt: Date?, updatedAt: Date?) {
		self.id = id
		self.professionCategoryId = professionCategoryId
		self.name = name
		self.createdAt = createdAt
		self.updatedAt = updatedAt
	}
}

public struct RoleData: Codable {
	public let userId: String?
	public let roleId: Int?
	public let createdAt, updatedAt: Date?
	public let role: RoleElement?

	public init(userId: String?, roleId: Int?, createdAt: Date?, updatedAt: Date?, role: RoleElement?) {
		self.userId = userId
		self.roleId = roleId
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.role = role
	}
}

public struct RoleElement: Codable, Equatable {
	public let id: Int?
	public let name: String?

	public init(id: Int?, name: String?) {
		self.id = id
		self.name = name
	}
}

public struct HighlightData: Codable {
	public static func == (lhs: HighlightData, rhs: HighlightData) -> Bool {
		lhs.id.orZero() == rhs.id.orZero()
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}

	public let id: Int?
	public let imgUrl: String?
	public let userId: String?
	public let createdAt: Date?
	public let updateAt: Date?

	public init(id: Int?, imgUrl: String?, userId: String?, createdAt: Date?, updateAt: Date?) {
		self.id = id
		self.imgUrl = imgUrl
		self.userId = userId
		self.createdAt = createdAt
		self.updateAt = updateAt
	}
}

public struct UserManagementData: Codable {
	public let id: Int?
	public let code: String?
	public let userId: String?
	public let createdAt: Date?
	public let updatedAt: Date?
	public let managementTalents: [UserDataOfManagement]?

	public init(id: Int?, code: String?, userId: String?, createdAt: Date?, updatedAt: Date?, managementTalents: [UserDataOfManagement]?) {
		self.id = id
		self.code = code
		self.userId = userId
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.managementTalents = managementTalents
	}
}

public struct ManagementWrappedData: Codable, Hashable {
    public let id: Int?
    public let managementId: Int?
    public let userId: String?
    public let management: UserDataOfManagement?
    
    public init(id: Int?, managementId: Int?, userId: String?, management: UserDataOfManagement?) {
        self.id = id
        self.managementId = managementId
        self.userId = userId
        self.management = management
    }

    public static func == (lhs: ManagementWrappedData, rhs: ManagementWrappedData) -> Bool {
        lhs.id.orZero() == rhs.id.orZero()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.orZero())
    }
}

public struct UserDataOfManagement: Codable, Hashable {
    
	public let createdAt: Date?
	public let id: Int?
	public let updatedAt: Date?
	public let user: ManagementTalentData?
	public let userId: String?

	public init(createdAt: Date?, id: Int?, updatedAt: Date?, user: ManagementTalentData?, userId: String?) {
		self.createdAt = createdAt
		self.id = id
		self.updatedAt = updatedAt
		self.user = user
		self.userId = userId
	}
    
    public static func == (lhs: UserDataOfManagement, rhs: UserDataOfManagement) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.orZero())
    }
}

public struct ManagementTalentData: Codable {
	public let id: String?
	public let name: String?
	public let username: String?
	public let profilePhoto: String?
	public let profileDescription: String?
	public let professions: [ProfessionData]?
	public let userHighlights: [HighlightData]?
	public let isVerified: Bool?
	public let isVisible: Bool?
	public let isActive: Bool?

	public init(id: String?, name: String?, username: String?, profilePhoto: String?, profileDescription: String?, professions: [ProfessionData]?, userHighlights: [HighlightData]?, isVerified: Bool?, isVisible: Bool?, isActive: Bool?) {
		self.id = id
		self.name = name
		self.username = username
		self.profilePhoto = profilePhoto
		self.profileDescription = profileDescription
		self.professions = professions
		self.userHighlights = userHighlights
		self.isVerified = isVerified
		self.isVisible = isVisible
		self.isActive = isActive
	}
}

//{
//	"id": 1,
//	"userManagementId": 2,
//	"userId": "c6127652d2e84b1198b3a8c035814267",
//	"createdAt": "2022-12-15T17:24:17.267Z",
//	"updatedAt": "2022-12-15T17:24:17.267Z",
//	"userManagement": {
//		"id": 2,
//		"code": "MCDE",
//		"userId": "657514285c0e817fcfde43b30e811f2d",
//		"createdAt": "2022-12-15T17:23:51.019Z",
//		"updatedAt": "2022-12-15T17:23:51.019Z",
//		"user": {
//			"id": "657514285c0e817fcfde43b30e811f2d",
//			"name": "Rumah Kita Sendiri",
//			"username": "buonobane",
//			"profilePhoto": "https://dinotis-public.s3.ap-southeast-1.amazonaws.com/5dd73b87b18644c5bec381be9c97fd78.png",
//			"profileDescription": "Abrakadabra",
//			"isVerified": false,
//			"isVisible": true,
//			"isActive": true
//		}
//	}
//}
