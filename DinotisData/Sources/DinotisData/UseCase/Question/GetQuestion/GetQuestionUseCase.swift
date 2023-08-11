//
//  File.swift
//  
//
//  Created by mora hakim on 09/08/23.
//

import Foundation

public protocol GetQuestionUseCase {
    func execute(for meetingId: String) async -> Result<QuestionResponse, Error>
}
