//
//  File.swift
//  
//
//  Created by Garry on 27/01/23.
//

import Foundation

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
        meetingUploads: [MeetingUploadData]?
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
    public let user: UserResponse?
    
    public init(id: Int?, meetingId: String?, username: String?, user: UserResponse?) {
        self.id = id
        self.meetingId = meetingId
        self.username = username
        self.user = user
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
