//
//  File.swift
//  
//
//  Created by mora hakim on 09/08/23.
//

import Foundation

public protocol SendQuestionUseCase {
    func execute(params: QuestionRequest) async -> Result<QuestionData, Error>
}
