//
//  QuestionDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Garry on 09/08/22.
//

import Foundation
import Moya
import Combine

final class QuestionDefaultRemoteDataSource: QuestionRemoteDataSource {
    
    private let provider: MoyaProvider<QuestionTargetType>
    
    init(provider: MoyaProvider<QuestionTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    func getQuestion(meetingId: String) -> AnyPublisher<Question, UnauthResponse> {
        self.provider.request(.getQuestion(meetingId), model: Question.self)
    }
    
    func sendQuestion(params: QuestionParams) -> AnyPublisher<QuestionResponse, UnauthResponse> {
        self.provider.request(.sendQuestion(params), model: QuestionResponse.self)
    }
    
    func putQuestion(questionId: Int, params: QuestionBodyParam) -> AnyPublisher<QuestionResponse, UnauthResponse> {
        self.provider.request(.putQuestion(questionId, params), model: QuestionResponse.self)
    }
}
