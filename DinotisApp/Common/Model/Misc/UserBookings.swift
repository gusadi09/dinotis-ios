//
//  UserBookings.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/10/21.
//

import Foundation

struct UserBooking: Codable {
	var id, bookedAt: String?
	var canceledAt, doneAt: String?
	var isFailed: Bool?
	var meetingID, userID, createdAt, updatedAt: String?
	var bookingPayment: UserBookingPayment
	var meeting: UserMeeting
	
	enum CodingKeys: String, CodingKey {
		case id, bookedAt, canceledAt, doneAt
		case meetingID = "meetingId"
		case userID = "userId"
		case createdAt, updatedAt, bookingPayment, meeting, isFailed
	}
}

struct DetailBooking: Codable {
	var meeting: UserMeeting
	let bookingPayment: BookingPayment?
	
	enum CodingKeys: String, CodingKey {
		case meeting, bookingPayment
	}
}

// MARK: - BookingPayment
struct UserBookingPayment: Codable {
	var id, amount: String?
	var paidAt: String?
	var failedAt: String?
	var bookingID: String?
	var paymentMethodID: Int?
	let externalId: String?
	let redirectUrl: String?
	let qrCodeUrl: String?
	var paymentMethod: PaymentMethod?
	
	enum CodingKeys: String, CodingKey {
		case id, amount, paidAt, failedAt
		case bookingID = "bookingId"
		case paymentMethodID = "paymentMethodId"
		case paymentMethod, redirectUrl, qrCodeUrl, externalId
	}
}

struct PrivateFeatureMeeting: Codable {
	let data: [UserMeeting]?
}

struct OriginalSectionResponse: Codable {
	let data: [OriginalSectionData]
	let nextCursor: Int?
}

struct OriginalSectionData: Codable {
	let id: Int?
	let name: String?
	let isActive: Bool?
	let landingPageListContentList: [LandingPageContentData]
	let user: User?

	static func == (lhs: OriginalSectionData, rhs: OriginalSectionData) -> Bool {
		return lhs.id.orZero() == rhs.id.orZero()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}
}

struct LandingPageContentData: Codable {
	let id: Int?
	let userId: String?
	let meetingId: String?
	let landingPageListId: Int?
	let user: User?
	let meeting: UserMeeting?
	let isActive: Bool?
	let createdAt: String?
	let updatedAt: String?

	static func == (lhs: LandingPageContentData, rhs: LandingPageContentData) -> Bool {
		return lhs.id.orZero() == rhs.id.orZero()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}
}

// MARK: - Meeting
struct UserMeeting: Codable {
	var id: String
	var title, meetingDescription, price: String?
	var startAt, endAt: String?
	var isPrivate: Bool?
	var isLiveStreaming: Bool?
	var slots: Int?
	var userID: String?
	var startedAt, endedAt: String?
	var createdAt, updatedAt: String?
	var deletedAt: String?
	var bookings: [Booked]?
	var user: User?
	
	enum CodingKeys: String, CodingKey {
		case id, title
		case meetingDescription = "description"
		case price, startAt, endAt, isPrivate, slots, isLiveStreaming
		case userID = "userId"
		case startedAt, endedAt, createdAt, updatedAt, deletedAt, bookings, user
	}
}

// MARK: - Booking
struct Booked: Codable {
	var id, bookedAt: String?
	var canceledAt, doneAt: String?
	var meetingID, userID, createdAt, updatedAt: String?
	var bookingPayment: BookingPayment
	var user: User
	
	enum CodingKeys: String, CodingKey {
		case id, bookedAt, canceledAt, doneAt
		case meetingID = "meetingId"
		case userID = "userId"
		case createdAt, updatedAt, bookingPayment, user
	}
}

// MARK: - User
struct User: Codable {
	var id, name, username, email: String?
	var profilePhoto: String?
	var isVerified: Bool?
	
	enum CodingKeys: String, CodingKey {
		case id, name, username, email, profilePhoto
		case isVerified
	}
}

struct UserBookings: Codable {
	var data: [UserBooking]
}

struct ExtraFeeResponse: Codable {
	let extraFee: Int?
}
