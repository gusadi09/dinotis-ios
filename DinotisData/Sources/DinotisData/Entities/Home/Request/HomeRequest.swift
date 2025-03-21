//
//  File.swift
//  
//
//  Created by Gus Adi on 30/03/23.
//

import Foundation

public struct HomeContentRequest: Codable {
    public var query: String?
    public var skip: Int
    public var take: Int
    public var sort: GeneralSorting
    
    public init(query: String? = nil, skip: Int = 0, take: Int = 10, sort: GeneralSorting = .newest) {
        self.query = query
        self.skip = skip
        self.take = take
        self.sort = sort
    }
}

public struct FollowingContentRequest: Codable {
    public var query: String?
    public var skip: Int
    public var take: Int
    public var sort: GeneralSorting
    public var followed: Bool
    
    public init(query: String? = nil, skip: Int = 0, take: Int = 10, sort: GeneralSorting = .newest, followed: Bool = false) {
        self.query = query
        self.skip = skip
        self.take = take
        self.sort = sort
        self.followed = followed
    }
}
