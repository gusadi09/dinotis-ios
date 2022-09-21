//
//  QuestionDefaultRepository.swift
//  DinotisApp
//
//  Created by Garry on 09/08/22.
//

import Foundation
import Combine

final class QuestionDefaultRepository: QuestionRepository {
    
    private let remote: QuestionRemoteDataSource
    
    init(remote: QuestionRemoteDataSource = QuestionDefaultRemoteDataSource()) {
        self.remote = remote
    }
    
    func provideGetQuestion(meetingId: String) -> AnyPublisher<Question, UnauthResponse> {
        self.remote.getQuestion(meetingId: meetingId)
    }
    
    func provideSendQuestion(params: QuestionParams) -> AnyPublisher<QuestionResponse, UnauthResponse> {
        self.remote.sendQuestion(params: params)
    }
    
    func providePutQuestion(questionId: Int, params: QuestionBodyParam) -> AnyPublisher<QuestionResponse, UnauthResponse> {
        self.remote.putQuestion(questionId: questionId, params: params)
    }
}
