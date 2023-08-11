//
//  File.swift
//  
//
//  Created by mora hakim on 09/08/23.
//

import Foundation

public protocol PutQuestionUseCase {
    func execute(questionId: Int, params: AnsweredRequest) async -> Result<QuestionData, Error>
}
