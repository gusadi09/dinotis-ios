//
//  File.swift
//  
//
//  Created by Garry on 27/01/23.
//

import Foundation

public struct SearchResponse: Codable {
    public let data: [MeetingDetailResponse]?
    public let nextCursor: Int?
    
    public init(data: [MeetingDetailResponse]?, nextCursor: Int?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}

public enum ReccomendType: Codable {
    case creator
    case session
}

public struct ReccomendData: Codable {
    public let name: String
    public let type: ReccomendType
    
    public init(name: String, type: ReccomendType) {
        self.name = name
        self.type = type
    }
}

public struct RecommendationResponse: Codable {
    public let data: [UserResponse]?
    public let nextCursor: Int?
    
    public init(data: [UserResponse]?, nextCursor: Int?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}

public struct SearchedResponse: Codable {
	public let data: [TalentWithProfessionData]?
	public let nextCursor: Int?

	public init(data: [TalentWithProfessionData]?, nextCursor: Int?) {
		self.data = data
		self.nextCursor = nextCursor
	}
}
