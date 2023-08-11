//
//  File.swift
//  
//
//  Created by mora hakim on 09/08/23.
//

import Foundation

public struct QuestionRequest: Codable {
    public let question: String
    public let meetingId: String
    public let userId: String
    
    public init(question: String, meetingId: String, userId: String) {
        self.question = question
        self.meetingId = meetingId
        self.userId = userId
    }
}

public struct AnsweredRequest: Codable {
    public let isAnswered: Bool
    
    public init(isAnswered: Bool) {
        self.isAnswered = isAnswered
    }
}
