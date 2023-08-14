//
//  File.swift
//  
//
//  Created by Gus Adi on 09/08/23.
//

import Foundation

public protocol DeleteCreatorMeetingUseCase {
    func execute(for meetingId: String) async -> Result<SuccessResponse, Error>
}
