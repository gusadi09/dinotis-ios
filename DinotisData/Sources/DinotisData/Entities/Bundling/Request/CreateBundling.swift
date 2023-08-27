//
//  File.swift
//  
//
//  Created by Irham Naufal on 23/08/23.
//

import Foundation

public struct CreateBundling: Codable {
    public let title: String
    public let description: String
    public let price: Int
    public let meetings: [String]
    
    public init(
        title: String,
        description: String,
        price: Int,
        meetings: [String]
    ) {
        self.title = title
        self.description = description
        self.price = price
        self.meetings = meetings
    }
}

public struct UpdateBundlingBody: Codable {
    public let title: String
    public let description: String
    public let price: Int
    public let meetingIds: [String]
    
    public init(
        title: String,
        description: String,
        price: Int,
        meetingIds: [String]
    ) {
        self.title = title
        self.description = description
        self.price = price
        self.meetingIds = meetingIds
    }
}

public struct BundlingListFilter: Codable {
    public var take: Int = 15
    public var skip: Int = 0
    public var isAvailable: String = ""
    
    public init(take: Int, skip: Int, isAvailable: String = "") {
        self.take = take
        self.skip = skip
        self.isAvailable = isAvailable
    }
}
