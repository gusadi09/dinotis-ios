//
//  File.swift
//  
//
//  Created by Garry on 27/01/23.
//

import Foundation

public struct SearchQueryParam: Codable {
    public var query: String
    public var skip: Int
    public var take: Int
    public var sort: GeneralSorting?
    public var profession: Int?
    public var professionCategory: Int?
    
    public init(
        query: String,
        skip: Int,
        take: Int,
        sort: GeneralSorting? = nil,
        profession: Int? = nil,
        professionCategory: Int? = nil
    ) {
        self.query = query
        self.skip = skip
        self.take = take
        self.profession = profession
        self.professionCategory = professionCategory
        self.sort = sort
    }
}
