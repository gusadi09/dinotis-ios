//
//  File.swift
//  
//
//  Created by Gus Adi on 24/07/23.
//

import Foundation
import Moya

public final class DyteDefaultRemoteDataSource: DyteRemoteDataSource {

    private let provider: MoyaProvider<DyteTargetType>
    
    public init(provider: MoyaProvider<DyteTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    public func addDyteParticipant(at meetingId: String) async throws -> DyteResponse {
        try await provider.request(.addParticipant(meetingId), model: DyteResponse.self)
    }
}
