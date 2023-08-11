//
//  File.swift
//  
//
//  Created by mora hakim on 07/08/23.
//

import Foundation

public struct QuestionData: Codable, Hashable {
    public let id: Int?
    public let question: String?
    public let meetingId: String?
    public let userId: String?
    public let isAnswered: Bool?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let user: UserResponse?
    
    public init(id: Int?, question: String?, meetingId: String?, userId: String?, isAnswered: Bool?, createdAt: Date?, updatedAt: Date?, user: UserResponse?) {
        self.id = id
        self.question = question
        self.meetingId = meetingId
        self.userId = userId
        self.isAnswered = isAnswered
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.user = user
    }
    
    public static func == (lhs: QuestionData, rhs: QuestionData) -> Bool {
        return lhs.id.orZero() == rhs.id.orZero()
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.orZero())
    }
}

public typealias QuestionResponse = [QuestionData]
