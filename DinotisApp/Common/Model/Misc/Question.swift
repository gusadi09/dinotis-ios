//
//  Question.swift
//  DinotisApp
//
//  Created by Garry on 11/08/22.
//

import Foundation

struct QuestionParams: Codable {
    let question: String
    let meetingId: String
    let userId: String
}

struct QuestionResponse: Codable, Hashable {
    let id: Int?
    let question: String?
    let meetingId: String?
    let userId: String?
    let isAnswered: Bool?
    let createdAt: String?
    let updatedAt: String?
    let user: Users?
    
    static func == (lhs: QuestionResponse, rhs: QuestionResponse) -> Bool {
        return lhs.id.orZero() == rhs.id.orZero()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.orZero())
    }
}

struct QuestionBodyParam: Codable {
    let isAnswered: Bool
}

typealias Question = [QuestionResponse]
