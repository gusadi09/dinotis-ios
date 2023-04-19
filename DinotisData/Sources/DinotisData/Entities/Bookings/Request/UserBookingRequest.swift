//
//  File.swift
//  
//
//  Created by Irham Naufal on 13/02/23.
//

import Foundation

public struct UserBookingQueryParam: Codable {
    public var skip: Int
    public var take: Int
    public var status: String
    
    public init(
        skip: Int,
        take: Int,
        status: String
    ) {
        self.status = status
        self.skip = skip
        self.take = take
    }
}
