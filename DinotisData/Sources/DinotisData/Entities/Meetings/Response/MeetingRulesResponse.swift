//
//  File.swift
//  
//
//  Created by Gus Adi on 07/08/23.
//

import Foundation

public struct MeetingRulesResponse: Codable, Hashable {

    public let id: Int?
    public let content: String?
    public let isActive: Bool?
    
    public init(id: Int?, content: String?, isActive: Bool?) {
        self.id = id
        self.content = content
        self.isActive = isActive
    }
    
    public static func == (lhs: MeetingRulesResponse, rhs: MeetingRulesResponse) -> Bool {
        lhs.id.orZero() == rhs.id.orZero()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.orZero())
    }
}
