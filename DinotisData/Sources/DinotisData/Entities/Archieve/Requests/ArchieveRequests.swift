//
//  File.swift
//  
//
//  Created by Gus Adi on 14/11/23.
//

import Foundation

public struct VideosRequest: Codable {
    public var cover: String
    public var title: String
    public var description: String
    public var videoUrl: String
    public var meetingId: String?
    public var audienceType: String
    
    public init(cover: String, title: String, description: String, videoUrl: String, meetingId: String?, audienceType: String) {
        self.cover = cover
        self.title = title
        self.description = description
        self.videoUrl = videoUrl
        self.meetingId = meetingId
        self.audienceType = audienceType
    }
}

public struct MineVideoRequest: Codable {
    public var take: Int = 5
    public var skip: Int = 0
    public var sort: MineVideoSorting? = nil
    public var videoType: MineVideoVideoType? = nil
    
    public init(take: Int = 5, skip: Int = 0, sort: MineVideoSorting? = nil, videoType: MineVideoVideoType? = nil) {
        self.take = take
        self.skip = skip
        self.sort = sort
        self.videoType = videoType
    }
}
