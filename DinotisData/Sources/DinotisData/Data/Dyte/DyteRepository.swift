//
//  File.swift
//  
//
//  Created by Gus Adi on 24/07/23.
//

import Foundation

public protocol DyteRepository {
    func provideAddDyteParticipant(at meetingId: String) async throws -> DyteResponse
}
