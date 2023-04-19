//
//  SearchTalent.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/09/21.
//

import Foundation
import DinotisData

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
struct ProfessionTalent: Codable, Equatable {
	var profession: Professions?
  
  static func ==(lhs: ProfessionTalent, rhs: ProfessionTalent) -> Bool {
    return lhs.profession == rhs.profession
  }
}

// MARK: - ProfessionProfession
struct Professions: Codable, Equatable {
	var id: Int?
	var name: String?
  
  static func ==(lhs: Professions, rhs: Professions) -> Bool {
    return lhs.id == rhs.id
  }
}

struct QuerySearch: Codable {
	var query: String?
	var skip: Int?
	var take: Int?
	var profession: Int?
}

struct TalentFromSearch: Codable {
	let id: String?
	let name, username, profileDescription: String?
	let profilePhoto: String?
	let isVerified: Bool?
	let isFollowed: Bool?
	let rating: String?
	let meetingCount: Int?
	let followerCount: Int?
	let management: ManagementUserData?
	let managements: [ManagementData]?
	let professions: [ProfessionTalent]?
	let meetings: [Meeting]
	let userHighlights: [Highlights]?
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
	let managementTalents: [ManagementUser]?

	static func == (lhs: ManagementUserData, rhs: ManagementUserData) -> Bool {
		lhs.id.orZero() == rhs.id.orZero()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}
}

struct ManagementUser: Codable, Hashable {
	let id: Int?
	let userId: String?
	let user: UserResponse?

	static func == (lhs: ManagementUser, rhs: ManagementUser) -> Bool {
		lhs.id.orZero() == rhs.id.orZero()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}
}

struct ManagementData: Codable, Hashable {
	let id: Int?
	let managementId: Int?
    let userId: String?
	let management: UserManagement?

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
	let createdAt: Date?
	let updatedAt: Date?
	let user: Users?

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
    var createdAt: Date?
    var updateAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case imgUrl, userId, createdAt, updateAt
    }
}

// MARK: - Meeting
struct Meeting: Codable, Hashable {

	var id, title, meetingDescription, price: String?
	var startAt, endAt: Date?
	var isPrivate: Bool?
	var isLiveStreaming: Bool?
	var slots: Int?
	var userID: String?
	var startedAt: Date?
	var endedAt: Date?
	var createdAt, updatedAt: Date?
	var deletedAt: Date?
	var booking: Booking?
    var isSelected: Bool?
	let participants: Int?
	let isAlreadyBooked: Bool?
	let isFailed: Bool?
    var uid: Int?
    var isBundling: Bool?
    let roomSid: String?
    let meetingBundleId: String?
	let meetingRequest: MeetingRequestData?
	let background: [String]?
    let user: UserResponse?
    let meetingCollaborations: [MeetingCollaborationData]?
    let meetingUrls: [MeetingURLData]?
    let meetingUploads: [MeetingUploadData]?
	
	enum CodingKeys: String, CodingKey {
		case id, title
		case meetingDescription = "description"
		case price, startAt, endAt, isPrivate, slots, isLiveStreaming, meetingRequest
		case userID = "userId"
		case startedAt, endedAt, createdAt, updatedAt, deletedAt, booking, isBundling, participants, roomSid, meetingBundleId, isFailed, isAlreadyBooked, background, meetingCollaborations, meetingUrls, meetingUploads, user
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
	var id: String
	let bookedAt: Date?
	var canceledAt, doneAt: Date?
	var meetingID, userID: String?
	let createdAt, updatedAt: Date?
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
	var paidAt: Date?
	var failedAt: Date?
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
