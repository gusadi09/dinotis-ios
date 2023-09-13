//
//  File.swift
//  
//
//  Created by Garry on 27/01/23.
//

import Foundation

public struct TalentMeetingResponse: Codable {
    public let data: TalentMeetingData?
    public let filters: FilterData?
    public let counter: String?
    public let nextCursor: Int?
    
    public init(data: TalentMeetingData?, filters: FilterData?, counter: String?, nextCursor: Int?) {
        self.data = data
        self.filters = filters
        self.counter = counter
        self.nextCursor = nextCursor
    }
}

public struct CreatorMeetingWithStatusResponse: Codable {
    public let data: [MeetingDetailResponse]?
    public let counter: String?
    
    public init(data: [MeetingDetailResponse]?, counter: String?) {
        self.data = data
        self.counter = counter
    }
}

public struct TalentMeetingData: Codable {
    public let meetings: [MeetingDetailResponse]?
    public let bundles: [BundlingData]?
    
    public init(meetings: [MeetingDetailResponse]?, bundles: [BundlingData]?) {
        self.meetings = meetings
        self.bundles = bundles
    }
}

public struct FilterData: Codable {
    public let options: [OptionQueryResponse]?
    
    public init(options: [OptionQueryResponse]?) {
        self.options = options
    }
}

public struct ClosestMeetingResponse: Codable {
    public let data: [MeetingDetailResponse]?
    
    public init(data: [MeetingDetailResponse]?) {
        self.data = data
    }
}

public struct OptionQueryResponse: Codable, Identifiable {
    public let id = UUID()
    public let queries: [QueryData]?
    public let label: String?
    
    public init(queries: [QueryData]?, label: String?) {
        self.queries = queries
        self.label = label
    }
}

public struct QueryData: Codable, Identifiable {
    public let id = UUID()
    public let name: String?
    public let value: String?
    
    public init(name: String?, value: String?) {
        self.name = name
        self.value = value
    }
}

public struct MeetingDetailResponse: Codable, Hashable {
    public let id: String?
    public let title: String?
    public let description: String?
    public let price: String?
    public let startAt: Date?
    public let endAt: Date?
    public let isPrivate: Bool?
    public let isLiveStreaming: Bool?
    public let participants: Int?
    public let slots: Int?
    public let userId: String?
    public let startedAt: Date?
    public let endedAt: Date?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let deletedAt: Date?
    public let meetingBundleId: String?
    public let meetingRequestId: String?
    public let user: UserResponse?
	public let background: [String]?
    public let meetingCollaborations: [MeetingCollaborationData]?
    public let meetingUrls: [MeetingURLData]?
    public let meetingUploads: [MeetingUploadData]?
    public let isCollaborationAlreadyConfirmed: Bool?
    public let isAlreadyBooked: Bool?
    public let booking: UserBookingData?
    public let bookings: [UserBookingData]?
    public let meetingRequest: MeetingRequestData?
    public let managementId: Int?
    public let cancelOptions: [CancelOptionData]?
    public let maxEditAt: Date?
    public let status: String?
    public let roomSid: String?
    public let dyteMeetingId: String?
    public let isInspected: Bool?
    public let reviews: [ReviewSuccessResponse]?
    public let participantDetails: [UserResponse]?
    
    public init(
        id: String = "",
        title: String? = "",
        description: String? = "",
        price: String? = "",
        startAt: Date? = Date(),
        endAt: Date? = Date(),
        isPrivate: Bool? = false,
        isLiveStreaming: Bool? = false,
        participants: Int? = 0,
        slots: Int? = 0,
        userId: String? = "",
        startedAt: Date? = Date(),
        endedAt: Date? = Date(),
        createdAt: Date? = Date(),
        updatedAt: Date? = Date(),
        deletedAt: Date? = Date(),
        meetingBundleId: String? = "",
        meetingRequestId: String? = "",
        user: UserResponse?,
		background: [String]?,
        meetingCollaborations: [MeetingCollaborationData]?,
        meetingUrls: [MeetingURLData]?,
        meetingUploads: [MeetingUploadData]?,
        isCollaborationAlreadyConfirmed: Bool?,
        isAlreadyBooked: Bool? = false,
        booking: UserBookingData? = nil,
        bookings: [UserBookingData]? = nil,
        meetingRequest: MeetingRequestData? = nil,
        managementId: Int? = nil,
        cancelOptions: [CancelOptionData]? = [],
        maxEditAt: Date? = nil,
        status: String? = nil,
        roomSid: String? = nil,
        dyteMeetingId: String? = nil,
        isInspected: Bool? = nil,
        reviews: [ReviewSuccessResponse]? = [],
        participantDetails: [UserResponse]? = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.startAt = startAt
        self.endAt = endAt
        self.isPrivate = isPrivate
        self.isLiveStreaming = isLiveStreaming
        self.participants = participants
        self.slots = slots
        self.userId = userId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.meetingBundleId = meetingBundleId
        self.meetingRequestId = meetingRequestId
        self.user = user
		self.background = background
        self.meetingCollaborations = meetingCollaborations
        self.meetingUrls = meetingUrls
        self.meetingUploads = meetingUploads
        self.isCollaborationAlreadyConfirmed = isCollaborationAlreadyConfirmed
        self.isAlreadyBooked = isAlreadyBooked
        self.booking = booking
        self.bookings = bookings
        self.meetingRequest = meetingRequest
        self.managementId = managementId
        self.cancelOptions = cancelOptions
        self.maxEditAt = maxEditAt
        self.status = status
        self.roomSid = roomSid
        self.dyteMeetingId = dyteMeetingId
        self.isInspected = isInspected
        self.reviews = reviews
        self.participantDetails = participantDetails
    }
    
    public static func == (lhs: MeetingDetailResponse, rhs: MeetingDetailResponse) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct MeetingCollaborationData: Codable {
    public let id: Int?
    public let meetingId: String?
    public let username: String?
    public let approvedAt: Date?
    public let declinedAt: Date?
    public let user: UserResponse?
    
    public init(id: Int?, meetingId: String?, username: String?, user: UserResponse?, approvedAt: Date?, declinedAt: Date?) {
        self.id = id
        self.meetingId = meetingId
        self.username = username
        self.user = user
        self.approvedAt = approvedAt
        self.declinedAt = declinedAt
    }
}

public struct MeetingURLData: Codable, Equatable {
    public let id: Int?
    public let title: String?
    public let url: String?
    public let meetingId: String?
    
    public init(id: Int?, title: String?, url: String?, meetingId: String?) {
        self.id = id
        self.title = title
        self.url = url
        self.meetingId = meetingId
    }
  
    public static func == (lhs: MeetingURLData, rhs: MeetingURLData) -> Bool {
        lhs.id == rhs.id
    }
}

public struct MeetingUploadData: Codable {
    public let id: Int?
    public let url: String?
    public let meetingId: String?
    
    public init(id: Int?, url: String?, meetingId: String?) {
        self.id = id
        self.url = url
        self.meetingId = meetingId
    }
}
