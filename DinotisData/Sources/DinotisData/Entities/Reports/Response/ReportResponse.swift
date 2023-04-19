//
//  File.swift
//  
//
//  Created by Gus Adi on 14/03/23.
//

import Foundation

public struct ReportResponse: Codable {
    public let userId: String?
    
    public init(userId: String?) {
        self.userId = userId
    }
}

public struct ReportReasonData: Codable, Equatable {
    public let id: Int?
    public let name: String?

    public static func == (lhs: ReportReasonData, rhs: ReportReasonData) -> Bool {
        return lhs.id.orZero() == rhs.id.orZero()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.orZero())
    }
    
    public init(id: Int?, name: String?) {
        self.id = id
        self.name = name
    }
}

public typealias ReportReasonResponse = [ReportReasonData]
