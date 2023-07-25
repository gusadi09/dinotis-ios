//
//  File.swift
//  
//
//  Created by Gus Adi on 24/07/23.
//

import Foundation

public final class DyteDefaultRepository: DyteRepository {

    private let remote: DyteRemoteDataSource
    
    public init(remote: DyteRemoteDataSource = DyteDefaultRemoteDataSource()) {
        self.remote = remote
    }
    
    public func provideAddDyteParticipant(at meetingId: String) async throws -> DyteResponse {
        try await remote.addDyteParticipant(at: meetingId)
    }
}
