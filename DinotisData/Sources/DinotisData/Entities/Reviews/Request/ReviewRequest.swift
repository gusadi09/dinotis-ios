//
//  File.swift
//  
//
//  Created by Irham Naufal on 10/02/23.
//

import Foundation

public struct ReviewRequestBody: Codable {
    public var rating: Int?
    public var review: String
    public var meetingId: String?
    public var isGeneral: Bool?
    public var reasons: String?
    
    public init(
        rating: Int? = 0,
        review: String = "",
        meetingId: String? = "",
        isGeneral: Bool? = nil,
        reasons: String? = nil
    ) {
        self.rating = rating
        self.review = review
        self.meetingId = meetingId
        self.isGeneral = isGeneral
        self.review = review
    }
}
