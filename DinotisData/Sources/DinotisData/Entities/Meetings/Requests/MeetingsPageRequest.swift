//
//  File.swift
//  
//
//  Created by Gus Adi on 07/08/23.
//

import Foundation

public struct MeetingsPageRequest: Codable {
    public var take: Int
    public var skip: Int
    public var isStarted: String
    public var isEnded: String
    public var isAvailable: String
    
    public init(take: Int = 15, skip: Int = 0, isStarted: String = "", isEnded: String = "", isAvailable: String = "") {
        self.take = take
        self.skip = skip
        self.isStarted = isStarted
        self.isEnded = isEnded
        self.isAvailable = isAvailable
    }
}
