//
//  File.swift
//  
//
//  Created by Gus Adi on 07/08/23.
//

import Foundation

public struct AddMeetingRequest: Codable {
    public var title: String
    public var description: String
    public var price: Int
    public var startAt: String
    public var endAt: String
    public var isPrivate: Bool
    public var slots: Int
    public var managementId: Int?
    public var urls: [MeetingURLrequest]
    public var collaborations: [String]?
    public var userFeePercentage: Int?
    public var talentFeePercentage: Int?
    public var archiveRecording: Bool
    
    public init(title: String, description: String, price: Int, startAt: String, endAt: String, isPrivate: Bool, slots: Int, managementId: Int? = nil, urls: [MeetingURLrequest], collaborations: [String]? = nil, userFeePercentage: Int? = nil, talentFeePercentage: Int? = nil, archiveRecording: Bool) {
        self.title = title
        self.description = description
        self.price = price
        self.startAt = startAt
        self.endAt = endAt
        self.isPrivate = isPrivate
        self.slots = slots
        self.managementId = managementId
        self.urls = urls
        self.collaborations = collaborations
        self.userFeePercentage = userFeePercentage
        self.talentFeePercentage = talentFeePercentage
        self.archiveRecording = archiveRecording
    }
}

public struct MeetingURLrequest: Codable {
    public var title: String
    public var url: String
    
    public init(title: String, url: String) {
        self.title = title
        self.url = url
    }
}
