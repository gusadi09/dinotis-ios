//
//  TalentMeeting.swift
//  DinotisApp
//
//  Created by Gus Adi on 12/10/21.
//

import Foundation
import DinotisData

struct TalentMeeting: Codable {
	var data: TalentMeetingData?
	let filters: FilterData?
	let counter: String?
	var nextCursor: Int?
}

struct TalentMeetingData: Codable {
	let meetings: [Meeting]?
	let bundles: [BundlingData]?
}

struct EditTalentResponse: Codable {
	let title: String?
	let description: String?
	let talentAdditionalEmail: String?
	let price: String?
	let startAt: Date?
	let endAt: Date?
	let isPrivate: Bool?
	let slots: Int?
}

struct MeetingOfTalent: Codable {
	var id: String
	var title, description, price: String?
	let startAt: Date?
	var endAt: Date?
	var isPrivate: Bool?
	var isLiveStreaming: Bool?
	var slots: Int?
	var userID: String?
	var startedAt: String?
	var endedAt: Date?
	var createdAt, updatedAt: Date?
	var deletedAt: Date?
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
	var id: String
	let bookedAt: Date?
	var canceledAt, doneAt: Date?
	var meetingID: String?
	var userID: String?
	let createdAt, updatedAt: Date?
	var bookingPayment: BookingPaymentOfTalent?
	
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
	var paidAt, failedAt: Date?
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
	var startAt: Date?
	var endAt: Date?
	var isPrivate: Bool?
	var isLiveStreaming: Bool?
	let participants: Int?
	var slots: Int?
	var userID: String?
	let startedAt: Date?
	var endedAt: Date?
	var createdAt, updatedAt: Date?
	var deletedAt: Date?
	let meetingBundleId: String?
	let meetingRequestId: String?
	let user: User?
	var bookings: [BookingMeeting]?
	var participantDetails: [User]
	let status: String?
	let meetingRequest: MeetingRequestData?
	let cancelOptions: [CancelOptionData]?
    let meetingCollaborations: [MeetingCollaborationData]?
    let meetingUrls: [MeetingURLData]?
    let meetingUploads: [MeetingUploadData]?
    let managementId: Int?
	
	enum CodingKeys: String, CodingKey {
		case id, title
		case description = "description"
		case price, startAt, endAt, isPrivate, slots, isLiveStreaming, participantDetails
		case userID = "userId"
		case startedAt, endedAt, createdAt, updatedAt, deletedAt, bookings, participants, meetingBundleId, meetingRequestId, meetingRequest, status, cancelOptions, user, meetingCollaborations, meetingUrls, meetingUploads, managementId
	}
}

// MARK: - Booking
struct BookingMeeting: Codable {
	var id: String
	let bookedAt: Date?
	var canceledAt, doneAt: Date?
	var meetingID: String?
	var userID: String?
	let createdAt, updatedAt: Date?
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
	var id: String
	let amount: String?
	var paidAt: Date?
	var failedAt: Date?
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
	var emailVerifiedAt: Date?
	var isVerified, isPasswordFilled: Bool?
	var registeredWith: Int?
	var lastLoginAt: Date?
	let professionID: String?
	var createdAt, updatedAt: Date?
	
	enum CodingKeys: String, CodingKey {
		case id, name, username, email, password, profilePhoto, profileDescription, emailVerifiedAt, isVerified, isPasswordFilled, registeredWith, lastLoginAt
		case professionID = "professionId"
		case createdAt, updatedAt
	}
}

struct StartMeetingResponse: Codable {
	var id: String
	let title, description, price: String?
	var startAt, endAt: Date?
	var isPrivate: Bool?
	var slots: Int?
	var userID: String?
	let startedAt: Date?
	var endedAt: Date?
	var createdAt, updatedAt: Date?
	var deletedAt: Date?
	
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
    var managementId: Int?
  var urls: [MeetingURL]
}

struct MeetingURL: Codable {
  var title: String
  var url: String
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
