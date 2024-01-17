//
//  File.swift
//  
//
//  Created by Gus Adi on 30/03/23.
//

import Foundation

public struct BannerResponse: Codable {
    public let data: [BannerData]?
    
    public init(data: [BannerData]?) {
        self.data = data
    }
}

public struct BannerData: Codable, Identifiable {
    public let id: Int?
    public let title: String?
    public let url: String?
    public let imgUrl: String?
    public let caption: String?
    public let description: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(id: Int?, title: String?, url: String?, imgUrl: String?, caption: String?, description: String?, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.title = title
        self.url = url
        self.imgUrl = imgUrl
        self.caption = caption
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct DynamicHomeResponse: Codable {
    public let data: [DynamicHomeData]?
    public let nextCursor: Int?
    
    public init(data: [DynamicHomeData]?, nextCursor: Int?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}

public struct DynamicHomeData: Codable {
    public let id: Int?
    public let name: String?
    public let description: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let talentHomeTalentList: [TalentHomeData]?
    
    public init(id: Int?, name: String?, description: String?, createdAt: Date?, updatedAt: Date?, talentHomeTalentList: [TalentHomeData]?) {
        self.id = id
        self.name = name
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.talentHomeTalentList = talentHomeTalentList
    }
}

public struct TalentHomeData: Codable {
    public let id: Int?
    public let userId: String?
    public let homeTalentListId: Int?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let user: UserResponse?
    
    public init(id: Int?, userId: String?, homeTalentListId: Int?, createdAt: Date?, updatedAt: Date?, user: UserResponse?) {
        self.id = id
        self.userId = userId
        self.homeTalentListId = homeTalentListId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.user = user
    }
}

public struct AnnouncementResponse: Codable {
    public let data: [AnnouncementData]?
    public let nextCursor: Int?
    
    public init(data: [AnnouncementData]?, nextCursor: Int?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}

public struct AnnouncementData: Codable {
    public let id: Int?
    public let title: String?
    public let imgUrl: String?
    public let url: String?
    public let caption: String?
    public let description: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    public var showing: Bool? = true
    
    public init(id: Int?, title: String?, imgUrl: String?, url: String?, caption: String?, description: String?, createdAt: Date?, updatedAt: Date?, showing: Bool? = nil) {
        self.id = id
        self.title = title
        self.imgUrl = imgUrl
        self.url = url
        self.caption = caption
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.showing = showing
    }

    static func == (lhs: AnnouncementData, rhs: AnnouncementData) -> Bool {
        lhs.id.orZero() == rhs.id.orZero()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.orZero())
    }
}

public struct LatestNoticeData: Codable {
    public let id: UInt?
    public let url: String?
    public let title: String?
    public let description: String?
    public let isActive: Bool?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(id: UInt?, url: String?, title: String?, description: String?, isActive: Bool?, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.url = url
        self.title = title
        self.description = description
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public typealias LatestNoticesResponse = [LatestNoticeData]

public struct OriginalSectionResponse: Codable {
    public let data: [OriginalSectionData]?
    public let nextCursor: Int?
    
    public init(data: [OriginalSectionData]?, nextCursor: Int?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}

public struct OriginalSectionData: Codable {
    public let id: Int?
    public let name: String?
    public let isActive: Bool?
    public let landingPageListContentList: [LandingPageContentData]
    public let user: UserResponse?
    
    public init(id: Int?, name: String?, isActive: Bool?, landingPageListContentList: [LandingPageContentData], user: UserResponse?) {
        self.id = id
        self.name = name
        self.isActive = isActive
        self.landingPageListContentList = landingPageListContentList
        self.user = user
    }

    static func == (lhs: OriginalSectionData, rhs: OriginalSectionData) -> Bool {
        return lhs.id.orZero() == rhs.id.orZero()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.orZero())
    }
}

public struct LandingPageContentData: Codable {
    public  let id: Int?
    public let userId: String?
    public let meetingId: String?
    public let landingPageListId: Int?
    public let user: UserResponse?
    public let meeting: UserMeetingData?
    public let isActive: Bool?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(id: Int?, userId: String?, meetingId: String?, landingPageListId: Int?, user: UserResponse?, meeting: UserMeetingData?, isActive: Bool?, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.userId = userId
        self.meetingId = meetingId
        self.landingPageListId = landingPageListId
        self.user = user
        self.meeting = meeting
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func == (lhs: LandingPageContentData, rhs: LandingPageContentData) -> Bool {
        return lhs.id.orZero() == rhs.id.orZero()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.orZero())
    }
}

public struct FeatureMeetingResponse: Codable {
    public let data: [UserMeetingData]?
    
    public init(data: [UserMeetingData]?) {
        self.data = data
    }
}
