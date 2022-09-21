//
//  QuestionRemoteDataSource.swift
//  DinotisApp
//
//  Created by Garry on 09/08/22.
//

import Foundation
import Combine

protocol QuestionRemoteDataSource {
    func getQuestion(meetingId: String) -> AnyPublisher<Question, UnauthResponse>
    func sendQuestion(params: QuestionParams) -> AnyPublisher<QuestionResponse, UnauthResponse>
    func putQuestion(questionId: Int, params: QuestionBodyParam) -> AnyPublisher<QuestionResponse, UnauthResponse>
}
