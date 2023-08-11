//
//  File.swift
//  
//
//  Created by mora hakim on 07/08/23.
//

import Foundation

protocol QuestionRepository {
    func provideGetQuestion(meetingId: String) async throws -> QuestionResponse
    func provideSendQuestion(params: QuestionRequest) async throws -> QuestionData
    func providePutQuestion(questionId: Int, params: AnsweredRequest) async throws -> QuestionData
}
