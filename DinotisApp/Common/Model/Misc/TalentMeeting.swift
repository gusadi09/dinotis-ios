//
//  TalentMeeting.swift
//  DinotisApp
//
//  Created by Gus Adi on 12/10/21.
//

import Foundation

struct TalentMeeting: Codable {
	var data: [Meeting]
	let filters: FilterData?
	var nextCursor: Int?
}

struct EditTalentResponse: Codable {
	let title: String?
	let description: String?
	let talentAdditionalEmail: String?
	let price: String?
	let startAt: String?
	let endAt: String?
	let isPrivate: Bool?
	let slots: Int?
}

struct MeetingOfTalent: Codable {
	var id: String
	var title, description, price, startAt: String
	var endAt: String
	var isPrivate: Bool
	var isLiveStreaming: Bool?
	var slots: Int
	var userID: String
	var startedAt: String?
	var endedAt: String?
	var createdAt, updatedAt: String
	var deletedAt: String?
	var bookings: [BookingOfTalent]?
	
	enum CodingKeys: String, CodingKey {
		case id, title
		case description
		case price, startAt, endAt, isPrivate, slots, isLiveStreaming
		case userID = "userId"
		case startedAt, endedAt, createdAt, updatedAt, deletedAt, bookings
	}
}

// MARK: - Booking
struct BookingOfTalent: Codable {
	var id, bookedAt: String
	var canceledAt, doneAt: String?
	var meetingID: String
	var userID, createdAt, updatedAt: String
	var bookingPayment: BookingPaymentOfTalent
	
	enum CodingKeys: String, CodingKey {
		case id, bookedAt, canceledAt, doneAt
		case meetingID = "meetingId"
		case userID = "userId"
		case createdAt, updatedAt, bookingPayment
	}
}

// MARK: - BookingPayment
struct BookingPaymentOfTalent: Codable {
	var id, amount: String
	var paidAt, failedAt: String?
	var bookingID: String
	var paymentMethodID: Int
	
	enum CodingKeys: String, CodingKey {
		case id, amount, paidAt, failedAt
		case bookingID = "bookingId"
		case paymentMethodID = "paymentMethodId"
	}
}

struct DetailMeeting: Codable {
	var id: String
	var title: String?
	var description, price: String?
	var startAt: String?
	var endAt: String?
	var isPrivate: Bool?
	var isLiveStreaming: Bool?
	var slots: Int?
	var userID, startedAt: String?
	var endedAt: String?
	var createdAt, updatedAt: String?
	var deletedAt: String?
	var bookings: [BookingMeeting]?
	
	enum CodingKeys: String, CodingKey {
		case id, title
		case description = "description"
		case price, startAt, endAt, isPrivate, slots, isLiveStreaming
		case userID = "userId"
		case startedAt, endedAt, createdAt, updatedAt, deletedAt, bookings
	}
}

// MARK: - Booking
struct BookingMeeting: Codable {
	var id, bookedAt: String
	var canceledAt, doneAt: String?
	var meetingID: String?
	var userID, createdAt, updatedAt: String?
	var bookingPayment: BookingPaymentTalent?
	var user: UserTalents?
	
	enum CodingKeys: String, CodingKey {
		case id, bookedAt, canceledAt, doneAt
		case meetingID = "meetingId"
		case userID = "userId"
		case createdAt, updatedAt, bookingPayment, user
	}
}

// MARK: - BookingPayment
struct BookingPaymentTalent: Codable {
	var id, amount: String
	var paidAt: String?
	var failedAt: String?
	var bookingID: String?
	var paymentMethodID: Int?
	
	enum CodingKeys: String, CodingKey {
		case id, amount, paidAt, failedAt
		case bookingID = "bookingId"
		case paymentMethodID = "paymentMethodId"
	}
}

// MARK: - User
struct UserTalents: Codable {
	var id, name: String
	var username: String?
	var email: String?
	var password: String?
	var profilePhoto: String?
	var profileDescription: String?
	var emailVerifiedAt: String?
	var isVerified, isPasswordFilled: Bool?
	var registeredWith: Int?
	var lastLoginAt, professionID: String?
	var createdAt, updatedAt: String?
	
	enum CodingKeys: String, CodingKey {
		case id, name, username, email, password, profilePhoto, profileDescription, emailVerifiedAt, isVerified, isPasswordFilled, registeredWith, lastLoginAt
		case professionID = "professionId"
		case createdAt, updatedAt
	}
}

struct StartMeetingResponse: Codable {
	var id, title, description, price: String
	var startAt, endAt: String?
	var isPrivate: Bool
	var slots: Int
	var userID, startedAt: String
	var endedAt: String?
	var createdAt, updatedAt: String
	var deletedAt: String?
	
	enum CodingKeys: String, CodingKey {
		case id, title
		case description = "description"
		case price, startAt, endAt, isPrivate, slots
		case userID = "userId"
		case startedAt, endedAt, createdAt, updatedAt, deletedAt
	}
}

struct MeetingForm: Codable {
	var id: String?
	var title: String
	var description: String
	var price: Int
	var startAt: String
	var endAt: String
	var isPrivate: Bool
	var slots: Int
}

struct MeetingRulesResponse: Codable, Hashable {

	let id: Int?
	let content: String?
	let isActive: Bool?
	
	static func == (lhs: MeetingRulesResponse, rhs: MeetingRulesResponse) -> Bool {
		lhs.id.orZero() == rhs.id.orZero()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}
}
