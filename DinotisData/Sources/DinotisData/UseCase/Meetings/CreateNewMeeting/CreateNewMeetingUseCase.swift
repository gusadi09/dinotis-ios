//
//  File.swift
//  
//
//  Created by Gus Adi on 09/08/23.
//

import Foundation

public protocol CreateNewMeetingUseCase {
    func execute(from body: AddMeetingRequest) async -> Result<StartCreatorMeetingResponse, Error>
}
