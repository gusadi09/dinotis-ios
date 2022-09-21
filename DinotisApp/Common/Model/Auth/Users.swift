//
//  Users.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/09/21.
//

import Foundation

struct UpdateUser: Codable {
	var name: String?
	var username: String?
	var profilePhoto: String?
	var profileDescription: String?
    var userHighlights: [String]?
	var professions: [Int]?
	var password: String?
	var confirmPassword: String?
	
	enum CodingKeys: String, CodingKey {
		case name, username, profilePhoto, profileDescription
		case userHighlights, professions, password, confirmPassword
	}
}

struct Users: Codable {
	let id: String?
	let email: String?
	let name: String?
	let username: String?
	let phone: String?
	let profilePhoto: String?
	let profileDescription, emailVerifiedAt: String?
	let isVerified: Bool?
	let isPasswordFilled: Bool?
	let registeredWith: Int?
	let lastLoginAt, professionID: String?
	let createdAt, updatedAt: String?
	let roles: [RoleElement]?
	let balance: Balance?
	let profession: String?
	let professions: [ProfessionElement]?
	let calendar: String?
	let userHighlights: [Highlights]?
	let coinBalance: CoinBalanceData?

	static func == (lhs: Users, rhs: Users) -> Bool {
		return lhs.id.orEmpty() == rhs.id.orEmpty()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orEmpty())
	}
}

struct CoinBalanceData: Codable {
	let id: Int?
	let current: Int64?
	let userId: String?
	let updatedAt: String?

	static func == (lhs: CoinBalanceData, rhs: CoinBalanceData) -> Bool {
		return lhs.id.orZero() == rhs.id.orZero()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}
}

// MARK: - Balance
struct Balance: Codable {
	var id: Int?
	var current: String?
	var updatedAt: String?
	
	enum CodingKeys: String, CodingKey {
		case id, current
		case updatedAt
	}
}

// MARK: - ProfessionElement
struct ProfessionElement: Codable, Equatable {
	
	var userID: String
	var professionID: Int
	var createdAt, updatedAt: String
	var profession: ProfessionProfession
	
	enum CodingKeys: String, CodingKey {
		case userID = "userId"
		case professionID = "professionId"
		case createdAt, updatedAt, profession
	}
	
	static func == (lhs: ProfessionElement, rhs: ProfessionElement) -> Bool {
		return lhs.profession.id == rhs.profession.id
	}
}

// MARK: - ProfessionProfession
struct ProfessionProfession: Codable {
	var id: Int
	var professionCategoryId: Int?
	var name, createdAt, updatedAt: String
}

struct ParticipantMeeting: Codable {
	var userId: String
	var uid: UInt
}

struct ProfessionResponse: Codable {
	var data: [ProfessionProfession]?
	var nextCursor: Int?
}

// MARK: - RoleElement
struct RoleElement: Codable {
	var userID: String
	var roleID: Int
	var createdAt, updatedAt: String
	var role: RoleRole?
	
	enum CodingKeys: String, CodingKey {
		case userID = "userId"
		case roleID = "roleId"
		case createdAt, updatedAt, role
	}
}

// MARK: - RoleRole
struct RoleRole: Codable {
	var id: Int
	var name: String
}

// MARK: - UserDetail
struct UserDetail: Codable {
	var id: Int?
	var identityName, identityNumber, identityAddress, identityDateOfBirth: String?
	var identityPlaceOfBirth, phone: String?
	var userID, createdAt, updatedAt: String?
	
	enum CodingKeys: String, CodingKey {
		case id, identityName, identityNumber, identityAddress, identityDateOfBirth, identityPlaceOfBirth, phone
		case userID = "userId"
		case createdAt, updatedAt
	}
}

struct UsernameBody: Codable {
	var username: String
}

struct SuggestionBody: Codable {
	var name: String
}

struct CurrentBalance: Codable {
	let current: Int?
}

struct AddBankAccount: Codable {
	var bankId: Int
	var accountName: String
	var accountNumber: String
}

struct BankAccount: Codable {
	let id: Int?
	let accountName: String?
	let accountNumber: String?
	let bankId: Int?
	let userId: String?
	let createdAt: String?
	let updatedAt: String?
	let bank: Bank?
}

typealias BankAccResponse = [BankAccount]

struct WithdrawParams: Codable {
	var amount: Int
	var bankId: Int
	var accountName: String
	var accountNumber: String
}

struct HistoryTransaction: Codable {
	let id: Int
	let current: Int?
	let userId: String?
	let updatedAt: String?
	let balanceDetails: [BalanceDetails]?
}

struct BalanceDetails: Codable {
	let id: Int
	let amount: Int?
	let isOut: Bool?
	let balanceId: Int?
	let transactionId: String?
	let isConfirmed: Bool?
	let createdAt: String?
	let topUp: String?
	let balance: UserDetailBalance?
	let transaction: String?
	let withdraw: UserWithdrawHistory?
}

struct UserDetailBalance: Codable {
	let id: Int
	let current: Int?
	let userId: String?
	let updatedAt: String?
}

struct UserWithdrawHistory: Codable {
	let id: String
	let amount: Int?
	let isFailed: Bool?
	let doneAt: String?
	let bankAccountId: Int?
	let balanceDetailId: Int?
	let externalId: String?
	let createdAt: String?
	let updatedAt: String?
}
