//
//  File.swift
//  
//
//  Created by Gus Adi on 01/02/23.
//

import Foundation

public struct UserMeetingData: Codable {
	public let id: String?
	public let title, meetingDescription, price: String?
	public let startAt, endAt: Date?
	public let isPrivate: Bool?
	public let isLiveStreaming: Bool?
	public let slots: Int?
	public let participants: Int?
	public let userID: String?
	public let startedAt, endedAt: Date?
	public let createdAt, updatedAt: Date?
	public let deletedAt: Date?
	public let bookings: [BookedData]?
	public let user: UserResponse?
	public let participantDetails: [UserResponse]?
	public let meetingBundleId, meetingRequestId: String?
	public let status: String?
	public let meetingRequest: MeetingRequestData?
	public let expiredAt: Date?
	public let background: [String]?
    public let meetingCollaborations: [MeetingCollaborationData]?
    public let meetingUrls: [MeetingURLData]?
    public let meetingUploads: [MeetingUploadData]?
    public let roomSid: String?
    public let dyteMeetingId: String?
    public let isInspected: Bool?
    public let reviews: [ReviewSuccessResponse]?

	public enum CodingKeys: String, CodingKey {
		case id, title, roomSid, dyteMeetingId
		case meetingDescription = "description"
		case price, startAt, endAt, isPrivate, slots, isLiveStreaming, participantDetails, expiredAt
		case userID = "userId"
		case startedAt, endedAt, createdAt, updatedAt, deletedAt, bookings, user, participants, meetingBundleId, meetingRequestId, status, meetingRequest, background, meetingCollaborations, meetingUrls, meetingUploads, isInspected, reviews
	}

	public init(
		id: String?,
		title: String?,
		meetingDescription: String?,
		price: String?,
		startAt: Date?,
		endAt: Date?,
		isPrivate: Bool?,
		isLiveStreaming: Bool?,
		slots: Int?,
		participants: Int?,
		userID: String?,
		startedAt: Date?,
		endedAt: Date?,
		createdAt: Date?,
		updatedAt: Date?,
		deletedAt: Date?,
		bookings: [BookedData]?,
		user: UserResponse?,
		participantDetails: [UserResponse]?,
		meetingBundleId: String?,
		meetingRequestId: String?,
		status: String?,
		meetingRequest: MeetingRequestData?,
		expiredAt: Date?,
		background: [String]?,
        meetingCollaborations: [MeetingCollaborationData]?,
        meetingUrls: [MeetingURLData]?,
        meetingUploads: [MeetingUploadData]?,
        roomSid: String?,
        dyteMeetingId: String?,
        isInspected: Bool?,
        reviews: [ReviewSuccessResponse]?
	) {
		self.id = id
		self.title = title
		self.meetingDescription = meetingDescription
		self.price = price
		self.startAt = startAt
		self.endAt = endAt
		self.isPrivate = isPrivate
		self.isLiveStreaming = isLiveStreaming
		self.slots = slots
		self.participants = participants
		self.userID = userID
		self.startedAt = startedAt
		self.endedAt = endedAt
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.deletedAt = deletedAt
		self.bookings = bookings
		self.user = user
		self.participantDetails = participantDetails
		self.meetingBundleId = meetingBundleId
		self.meetingRequestId = meetingRequestId
		self.status = status
		self.meetingRequest = meetingRequest
		self.expiredAt = expiredAt
		self.background = background
        self.meetingCollaborations = meetingCollaborations
        self.meetingUrls = meetingUrls
        self.meetingUploads = meetingUploads
        self.roomSid = roomSid
        self.dyteMeetingId = dyteMeetingId
        self.isInspected = isInspected
        self.reviews = reviews
	}
}

public struct GeneralMeetingData: Codable, Hashable {

	public let id, title, meetingDescription, price: String?
	public let startAt, endAt: Date?
	public let isPrivate: Bool?
	public let isLiveStreaming: Bool?
	public let slots: Int?
	public let userID: String?
	public let startedAt: Date?
	public let endedAt: Date?
	public let createdAt, updatedAt: Date?
	public let deletedAt: Date?
	public let bookings: [BookedData]?
	public let isSelected: Bool?
	public let participants: Int?
	public let isAlreadyBooked: Bool?
	public let isFailed: Bool?
	public let uid: Int?
	public let isBundling: Bool?
	public let roomSid: String?
	public let meetingBundleId: String?
	public let meetingRequest: MeetingRequestData?
	public let background: [String]?
    public let meetingCollaborations: [MeetingCollaborationData]?
    public let meetingUrls: [MeetingURLData]?
    public let meetingUploads: [MeetingUploadData]?

	public enum CodingKeys: String, CodingKey {
		case id, title
		case meetingDescription = "description"
		case price, startAt, endAt, isPrivate, slots, isLiveStreaming
		case userID = "userId"
		case startedAt, endedAt, createdAt, updatedAt, deletedAt, bookings, isSelected, participants, isAlreadyBooked, isFailed, uid, isBundling, roomSid, meetingBundleId, meetingRequest, background, meetingCollaborations, meetingUrls, meetingUploads
	}

	public static func == (lhs: GeneralMeetingData, rhs: GeneralMeetingData) -> Bool {
		lhs.id.orEmpty() == rhs.id.orEmpty()
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id.orEmpty())
	}

	public init(
		id: String?,
		title: String?,
		meetingDescription: String?,
		price: String?,
		startAt: Date?,
		endAt: Date?,
		isPrivate: Bool?,
		isLiveStreaming: Bool?,
		slots: Int?,
		userID: String?,
		startedAt: Date?,
		endedAt: Date?,
		createdAt: Date?,
		updatedAt: Date?,
		deletedAt: Date?,
		bookings: [BookedData]?,
		isSelected: Bool?,
		participants: Int?,
		isAlreadyBooked: Bool?,
		isFailed: Bool?,
		uid: Int?,
		isBundling: Bool?,
		roomSid: String?,
		meetingBundleId: String?,
		meetingRequest: MeetingRequestData?,
		background: [String]?,
        meetingCollaborations: [MeetingCollaborationData]?,
        meetingUrls: [MeetingURLData]?,
        meetingUploads: [MeetingUploadData]?
	) {
		self.id = id
		self.title = title
		self.meetingDescription = meetingDescription
		self.price = price
		self.startAt = startAt
		self.endAt = endAt
		self.isPrivate = isPrivate
		self.isLiveStreaming = isLiveStreaming
		self.slots = slots
		self.userID = userID
		self.startedAt = startedAt
		self.endedAt = endedAt
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.deletedAt = deletedAt
		self.bookings = bookings
		self.isSelected = isSelected
		self.participants = participants
		self.isAlreadyBooked = isAlreadyBooked
		self.isFailed = isFailed
		self.uid = uid
		self.isBundling = isBundling
		self.roomSid = roomSid
		self.meetingBundleId = meetingBundleId
		self.meetingRequest = meetingRequest
		self.background = background
        self.meetingCollaborations = meetingCollaborations
        self.meetingUrls = meetingUrls
        self.meetingUploads = meetingUploads
	}
}

public struct MeetingRequestData: Codable, Hashable {
	public let id: String?
	public let message: String?
	public let isAccepted: Bool?
	public let isConfirmed: Bool?
	public let userId: String?
	public let user: UserResponse?
	public let rateCardId: String?
	public let rateCard: RateCardResponse?
	public let createdAt: Date?
	public let updatedAt: Date?
    public let expiredAt: Date?
	public let requestAt: Date?

	public static func == (lhs: MeetingRequestData, rhs: MeetingRequestData) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id.orEmpty())
	}

	public init(
		id: String?,
		message: String?,
		isAccepted: Bool?,
		isConfirmed: Bool?,
		userId: String?,
		user: UserResponse?,
		rateCardId: String?,
		rateCard: RateCardResponse?,
		createdAt: Date?,
		updatedAt: Date?,
        expiredAt: Date?,
        requestAt: Date?
	) {
		self.id = id
		self.message = message
		self.isAccepted = isAccepted
		self.isConfirmed = isConfirmed
		self.userId = userId
		self.user = user
		self.rateCardId = rateCardId
		self.rateCard = rateCard
		self.createdAt = createdAt
		self.updatedAt = updatedAt
        self.expiredAt = expiredAt
		self.requestAt = requestAt
	}
}
