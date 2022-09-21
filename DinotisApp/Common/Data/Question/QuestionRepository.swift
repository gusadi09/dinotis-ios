//
//  QuestionRepository.swift
//  DinotisApp
//
//  Created by Garry on 09/08/22.
//

import Foundation
import Combine

protocol QuestionRepository {
    func provideGetQuestion(meetingId: String) -> AnyPublisher<Question, UnauthResponse>
    func provideSendQuestion(params: QuestionParams) -> AnyPublisher<QuestionResponse, UnauthResponse>
    func providePutQuestion(questionId: Int, params: QuestionBodyParam) -> AnyPublisher<QuestionResponse, UnauthResponse>
}
