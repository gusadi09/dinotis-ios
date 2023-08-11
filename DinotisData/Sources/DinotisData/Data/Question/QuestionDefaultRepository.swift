//
//  File.swift
//  
//
//  Created by mora hakim on 08/08/23.
//

import Foundation

final class QuestionDefaultRepository: QuestionRepository {
    
    private let remote: QuestionRemoteDataSource
    
    init(remote: QuestionRemoteDataSource = QuestionDefaultRemoteDataSource()) {
        self.remote = remote
    }
    
    func provideGetQuestion(meetingId: String) async throws -> QuestionResponse {
        return try await remote.getQuestion(meetingId: meetingId)
    }
    
    func provideSendQuestion(params: QuestionRequest) async throws -> QuestionData {
        return try await remote.sendQuestion(params: params)
    }
    
    func providePutQuestion(questionId: Int, params: AnsweredRequest) async throws -> QuestionData {
        return try await remote.putQuestion(questionId: questionId, params: params)
    }
}
