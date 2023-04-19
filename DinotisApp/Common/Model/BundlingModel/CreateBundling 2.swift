//
//  CreateBundling.swift
//  DinotisApp
//
//  Created by Garry on 02/11/22.
//

import Foundation

struct CreateBundling: Codable {
    var title: String
    var description: String
    var price: String
    var meetings: [String]
}

struct CreateBundlingResponse: Codable {
    let id: String?
    let title: String?
    let description: String?
    let price: String?
    let createdAt: String?
    let updatedAt: String?
    
    static func == (lhs: CreateBundlingResponse, rhs: CreateBundlingResponse) -> Bool {
        return lhs.id.orEmpty() == rhs.id.orEmpty()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.orEmpty())
    }
}

struct MeetingListResponse: Codable {
    var data: [AvailableMeeting]
}

struct AvailableMeeting: Codable {
    let id: String?
    let title: String?
    let description: String?
    let price: String?
    let startAt: String?
    let endAt: String?
    let isPrivate: Bool?
    let slots: Int?
    let createdAt: String?
    let updatedAt: String?
    let userId: String?
    let deletedAt: String?
    let startedAt: String?
    let endedAt: String?
    let isLiveStreaming: String?
    let roomSid: String?
    let meetingBundleId: String?
    
    static func == (lhs: AvailableMeeting, rhs: AvailableMeeting) -> Bool {
        return lhs.id.orEmpty() == rhs.id.orEmpty()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.orEmpty())
    }
}
