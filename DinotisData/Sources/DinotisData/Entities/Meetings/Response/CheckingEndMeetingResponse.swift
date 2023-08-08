//
//  File.swift
//  
//
//  Created by Gus Adi on 07/08/23.
//

import Foundation

public struct CheckingEndMeetingResponse: Codable {
    public let endAt: Date?
    public let isEnd: Bool?
    
    public init(endAt: Date?, isEnd: Bool?) {
        self.endAt = endAt
        self.isEnd = isEnd
    }
}
