//
//  UserBookings.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/10/21.
//

import Foundation
import DinotisData

struct UserBooking: Codable {
	var id: String
	let bookedAt: Date?
	let invoiceId: String?
	var canceledAt, doneAt: Date?
	var isFailed: Bool?
    var isReviewed: Bool?
	var meetingID, userID: String?
	let createdAt, updatedAt: Date?
	var bookingPayment: UserBookingPayment?
	var meeting: UserMeeting?
	let meetingBundle: BundlingData?
    let status: String?
	
	enum CodingKeys: String, CodingKey {
		case id, bookedAt, canceledAt, doneAt
		case meetingID = "meetingId"
		case userID = "userId"
		case invoiceId
		case createdAt, updatedAt, bookingPayment, meeting, isFailed, isReviewed, meetingBundle, status
	}
}

struct DetailBooking: Codable {
	var meeting: UserMeeting?
	let bookingPayment: BookingPayment?
	
	enum CodingKeys: String, CodingKey {
		case meeting, bookingPayment
	}
}

// MARK: - BookingPayment
struct UserBookingPayment: Codable {
	var id, amount: String?
	var paidAt: Date?
	var failedAt: Date?
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

// MARK: - Meeting
struct UserMeeting: Codable {
	var id: String
	var title, meetingDescription, price: String?
	var startAt, endAt: Date?
	var isPrivate: Bool?
	var isLiveStreaming: Bool?
	var slots: Int?
	let participants: Int?
	var userID: String?
	var startedAt, endedAt: Date?
	var createdAt, updatedAt: Date?
	var deletedAt: Date?
	var bookings: [Booked]?
	var user: User?
	let participantDetails: [User]?
	let meetingBundleId, meetingRequestId: String?
	let status: String?
	let meetingRequest: MeetingRequestData?
	let expiredAt: Date?
    public let background: [String]?
	
	enum CodingKeys: String, CodingKey {
		case id, title
		case meetingDescription = "description"
		case price, startAt, endAt, isPrivate, slots, isLiveStreaming, participantDetails, expiredAt, background
		case userID = "userId"
		case startedAt, endedAt, createdAt, updatedAt, deletedAt, bookings, user, participants, meetingBundleId, meetingRequestId, status, meetingRequest
	}
}

// MARK: - Booking
struct Booked: Codable {
	var id: String
	let bookedAt: Date?
	var canceledAt, doneAt: Date?
	var meetingID, userID: String?
	let createdAt, updatedAt: Date?
	var bookingPayment: BookingPayment?
	var user: User?
	
	enum CodingKeys: String, CodingKey {
		case id, bookedAt, canceledAt, doneAt
		case meetingID = "meetingId"
		case userID = "userId"
		case createdAt, updatedAt, bookingPayment, user
	}
}

// MARK: - User
struct User: Codable, Identifiable, Hashable {
	var id: String
	var name, username, email: String?
	var profilePhoto: String?
	var isVerified: Bool?
	
	enum CodingKeys: String, CodingKey {
		case id, name, username, email, profilePhoto
		case isVerified
	}
}

struct UserBookings: Codable {
	var data: [UserBooking]
    let nextCursor: Int?
}

struct ExtraFeeResponse: Codable {
	let extraFee: Int?
}
