//
//  File.swift
//  
//
//  Created by Gus Adi on 24/07/23.
//

import Foundation

public protocol DyteRemoteDataSource {
    func addDyteParticipant(at meetingId: String) async throws -> DyteResponse
}
