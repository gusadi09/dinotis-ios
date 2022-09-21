//
//  SearchTalent.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/09/21.
//

import Foundation

struct SearchResponse: Codable {
	var data: [Talent]
	var nextCursor: Int?
}

// MARK: - Datum
struct Talent: Codable, Hashable {
	static func == (lhs: Talent, rhs: Talent) -> Bool {
		lhs.id.orEmpty() == rhs.id.orEmpty()
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orEmpty())
	}
	
	var id, username: String?
	var name: String?
	var profilePhoto: String?
	var profileDescription: String?
	var isVerified: Bool?
	var isActive: Bool?
	var isVisible: Bool?
	var professions: [ProfessionTalent]?
}

// MARK: - ProfessionElement
struct ProfessionTalent: Codable {
	var profession: Professions
}

// MARK: - ProfessionProfession
struct Professions: Codable {
	var id: Int?
	var name: String?
}

struct QuerySearch: Codable {
	var query: String?
	var skip: Int?
	var take: Int?
	var profession: Int?
}

struct TalentFromSearch: Codable {
	let id: String
	var name, username, profileDescription: String?
	var profilePhoto: String?
	var isVerified: Bool
	let userManagement: ManagementUserData?
	let userManagementTalent: ManagementData?
	var professions: [ProfessionTalent]
	var meetings: [Meeting]
	var userHighlights: [Highlights]?
}

struct FilterData: Codable {
	let options: [OptionQuery]?
}

struct OptionQuery: Codable, Identifiable {
	let id = UUID()
	let queries: [QueryData]?
	let label: String?
}

struct QueryData: Codable, Identifiable {
	let id = UUID()
	let name: String?
	let value: String?
}

struct ManagementUserData: Codable, Hashable {
	let id: Int?
	let code: String?
	let userId: String?
	let userManagementTalents: [ManagementUser]?

	static func == (lhs: ManagementUserData, rhs: ManagementUserData) -> Bool {
		lhs.id.orZero() == rhs.id.orZero()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}
}

struct ManagementUser: Codable, Hashable {
	let id: Int?
	let userManagementId: Int?
	let userId: String?
	let user: Talent?

	static func == (lhs: ManagementUser, rhs: ManagementUser) -> Bool {
		lhs.id.orZero() == rhs.id.orZero()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}
}

struct ManagementData: Codable, Hashable {
	let id: Int?
	let userManagementId: Int?
	let userId: String?
	let userManagement: UserManagement?

	static func == (lhs: ManagementData, rhs: ManagementData) -> Bool {
		lhs.id.orZero() == rhs.id.orZero()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}
}

struct UserManagement: Codable, Hashable {
	let id: Int?
	let code: String?
	let userId: String?
	let createdAt: String?
	let updatedAt: String?
	let user: Users

	static func == (lhs: UserManagement, rhs: UserManagement) -> Bool {
		lhs.id.orZero() == rhs.id.orZero()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}
}

struct Highlights: Codable {
    static func == (lhs: Highlights, rhs: Highlights) -> Bool {
        lhs.id.orZero() == rhs.id.orZero()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.orZero())
    }
    
    var id: Int?
    var imgUrl: String?
    var userId: String?
    var createdAt: String?
    var updateAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case imgUrl, userId, createdAt, updateAt
    }
}

// MARK: - Meeting
struct Meeting: Codable, Hashable {

	var id, title, meetingDescription, price: String?
	var startAt, endAt: String?
	var isPrivate: Bool?
	var isLiveStreaming: Bool?
	var slots: Int?
	var userID: String
	var startedAt: String?
	var endedAt: String?
	var createdAt, updatedAt: String
	var deletedAt: String?
	var bookings: [Booking]
	
	enum CodingKeys: String, CodingKey {
		case id, title
		case meetingDescription = "description"
		case price, startAt, endAt, isPrivate, slots, isLiveStreaming
		case userID = "userId"
		case startedAt, endedAt, createdAt, updatedAt, deletedAt, bookings
	}

	static func == (lhs: Meeting, rhs: Meeting) -> Bool {
		lhs.id.orEmpty() == rhs.id.orEmpty()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orEmpty())
	}
}

// MARK: - Booking
struct Booking: Codable {
	var id, bookedAt: String
	var canceledAt, doneAt: String?
	var meetingID, userID, createdAt, updatedAt: String?
	var bookingPayment: BookingPayment?
	
	enum CodingKeys: String, CodingKey {
		case id, bookedAt, canceledAt, doneAt
		case meetingID = "meetingId"
		case userID = "userId"
		case createdAt, updatedAt, bookingPayment
	}
}

// MARK: - BookingPayment
struct BookingPayment: Codable {
	var id: String
	var amount: String?
	var paidAt: String?
	var failedAt: String?
	var bookingID: String?
	var paymentMethodID: Int?
	var paymentMethod: PaymentMethod?
	
	enum CodingKeys: String, CodingKey {
		case id, amount, paidAt, failedAt
		case bookingID = "bookingId"
		case paymentMethodID = "paymentMethodId"
		case paymentMethod
	}
}
