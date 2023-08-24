//
//  File.swift
//  
//
//  Created by Gus Adi on 09/08/23.
//

import Foundation

public protocol EditCreatorMeetingUseCase {
    func execute(for meetingId: String, with params: AddMeetingRequest) async -> Result<StartCreatorMeetingResponse, Error>
}
