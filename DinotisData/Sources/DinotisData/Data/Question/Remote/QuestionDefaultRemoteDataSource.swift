//
//  File.swift
//  
//
//  Created by mora hakim on 08/08/23.
//

import Foundation
import Moya

public final class QuestionDefaultRemoteDataSource: QuestionRemoteDataSource {
    
    private let provider: MoyaProvider<QuestionTargetType>
    
    public init(provider: MoyaProvider<QuestionTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    public func getQuestion(meetingId: String) async throws -> QuestionResponse {
        try await self.provider.request(.getQuestion(meetingId), model: QuestionResponse.self)
    }
    
    public func sendQuestion(params: QuestionRequest) async throws -> QuestionData {
        try await self.provider.request(.sendQuestion(params), model: QuestionData.self)
    }
    
    public func putQuestion(questionId: Int, params: AnsweredRequest) async throws -> QuestionData {
        try await self.provider.request(.putQuestion(questionId, params), model: QuestionData.self)
    }
}

