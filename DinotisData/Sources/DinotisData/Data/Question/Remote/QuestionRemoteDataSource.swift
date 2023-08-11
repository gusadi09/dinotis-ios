//
//  File.swift
//  
//
//  Created by mora hakim on 08/08/23.
//

import Foundation

public protocol QuestionRemoteDataSource {
    func getQuestion(meetingId: String) async throws -> QuestionResponse
    func sendQuestion(params: QuestionRequest) async throws -> QuestionData
    func putQuestion(questionId: Int, params: AnsweredRequest) async throws -> QuestionData
}
