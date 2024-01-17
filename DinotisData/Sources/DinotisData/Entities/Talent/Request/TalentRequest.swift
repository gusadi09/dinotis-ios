//
//  File.swift
//  
//
//  Created by Gus Adi on 21/04/23.
//

import Foundation

public struct TalentsRequest: Codable {
    public var query: String?
    public var skip: Int
    public var take: Int
    public var profession: Int?
    public var professionCategory: Int?
    public var followed: Bool?
    
    public init(query: String? = nil, skip: Int, take: Int, profession: Int? = nil, professionCategory: Int? = nil, followed: Bool? = nil) {
        self.query = query
        self.skip = skip
        self.take = take
        self.profession = profession
        self.professionCategory = professionCategory
        self.followed = followed
    }
}
