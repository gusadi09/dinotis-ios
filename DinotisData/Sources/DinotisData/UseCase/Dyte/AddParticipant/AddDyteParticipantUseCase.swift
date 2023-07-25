//
//  File.swift
//  
//
//  Created by Gus Adi on 24/07/23.
//

import Foundation

public protocol AddDyteParticipantUseCase {
    func execute(for meetingId: String) async -> Result<DyteResponse, Error>
}
