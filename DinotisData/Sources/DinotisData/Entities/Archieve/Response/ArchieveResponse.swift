//
//  File.swift
//  
//
//  Created by Gus Adi on 14/11/23.
//

import Foundation

public struct VideosResponse: Codable {
    public let id: String?
    
    public init(id: String?) {
        self.id = id
    }
}

public struct MineVideoUserData: Codable {
    public let id: String?
    public let name: String?
    public let username: String?
    public let profilePhoto: String?
    public let isVerified: Bool?
    public let professions: [String]?
    
    public init(id: String?, name: String?, username: String?, profilePhoto: String?, isVerified: Bool?, professions: [String]?) {
        self.id = id
        self.name = name
        self.username = username
        self.profilePhoto = profilePhoto
        self.isVerified = isVerified
        self.professions = professions
    }
}

public struct MineVideoData: Codable, Hashable {
    public let id: String?
    public let cover: String?
    public let title: String?
    public let description: String?
    public let videoUrl: String?
    public let videoType: MineVideoVideoType?
    public let audienceType: MineVideoAudienceType?
    public let meetingId: String?
    public let userId: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let deletedAt: Date?
    public let user: MineVideoUserData?
    public let shareUrl: String?
    
    public init(id: String?, cover: String?, title: String?, description: String?, videoUrl: String?, videoType: MineVideoVideoType?, audienceType: MineVideoAudienceType?, meetingId: String?, userId: String?, createdAt: Date?, updatedAt: Date?, deletedAt: Date?, user: MineVideoUserData?, shareUrl: String?) {
        self.id = id
        self.cover = cover
        self.title = title
        self.description = description
        self.videoUrl = videoUrl
        self.videoType = videoType
        self.audienceType = audienceType
        self.meetingId = meetingId
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.user = user
        self.shareUrl = shareUrl
    }
    
    public static func == (lhs: MineVideoData, rhs: MineVideoData) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct MineVideoResponse: Codable {
    public let data: [MineVideoData]?
    public let nextCursor: Int?
    
    public init(data: [MineVideoData]?, nextCursor: Int?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}

public struct CommentsResponse: Codable {
    public let data: [GeneralComments]?
    public let nextCursor: Int?
    
    public init(data: [GeneralComments]?, nextCursor: Int?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}

public struct GeneralComments: Codable {
    public let id: String?
    public let videoId: String?
    public let comment: String?
    public let userId: String?
    public let createdAt: Date?
    public let user: UserResponse?
    
    public init(id: String?, videoId: String?, comment: String?, userId: String?, createdAt: Date?, user: UserResponse?) {
        self.id = id
        self.videoId = videoId
        self.comment = comment
        self.userId = userId
        self.createdAt = createdAt
        self.user = user
    }
}

public struct DetailVideosResponse: Codable {
    public let video: MineVideoData?
    public let meeting: MeetingDetailResponse?
    public let totalComment: Int?
    public let comment: GeneralComments?
    
    public init(video: MineVideoData?, totalComment: Int?, meeting: MeetingDetailResponse?, comment: GeneralComments?) {
        self.video = video
        self.totalComment = totalComment
        self.meeting = meeting
        self.comment = comment
    }
}

public struct RecordingResponse: Codable {
    public let data: [RecordingData]?
    public let counter: String?
    
    public init(data: [RecordingData]?, counter: String?) {
        self.data = data
        self.counter = counter
    }
}

public struct RecordingData: Codable {
    public let status: String?
    public let id: String?
    public let downloadUrl: String?
    public let downloadUrlExpiry: String?
    public let audioDownloadUrl: String?
    public let fileSize: Int?
    public let sessionId: String?
    public let outputFileName: String?
    public let invokedTime: String?
    public let startedTime: String?
    public let stoppedTime: String?
    public let recordingDuration: Int?
    public let meeting: MeetingDetailResponse?
    
    public init(status: String?, id: String?, downloadUrl: String?, downloadUrlExpiry: String?, audioDownloadUrl: String?, fileSize: Int?, sessionId: String?, outputFileName: String?, invokedTime: String?, startedTime: String?, stoppedTime: String?, recordingDuration: Int?, meeting: MeetingDetailResponse?) {
        self.status = status
        self.id = id
        self.downloadUrl = downloadUrl
        self.downloadUrlExpiry = downloadUrlExpiry
        self.audioDownloadUrl = audioDownloadUrl
        self.fileSize = fileSize
        self.sessionId = sessionId
        self.outputFileName = outputFileName
        self.invokedTime = invokedTime
        self.startedTime = startedTime
        self.stoppedTime = stoppedTime
        self.recordingDuration = recordingDuration
        self.meeting = meeting
    }
}

public struct ArchivedData: Codable {
    public let id: String?
    public let title: String?
    public let description: String?
    public let endAt: Date?
    public let dyteMeetingId: String?
    public let recordings: [RecordingData]?
    
    public init(id: String?, title: String?, description: String?, endAt: Date?, dyteMeetingId: String?, recordings: [RecordingData]?) {
        self.id = id
        self.title = title
        self.description = description
        self.endAt = endAt
        self.dyteMeetingId = dyteMeetingId
        self.recordings = recordings
    }
}

public struct ArchivedResponse: Codable {
    public let data: [ArchivedData]?
    public let nextCursor: Int?
    
    public init(data: [ArchivedData]?, nextCursor: Int?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}
