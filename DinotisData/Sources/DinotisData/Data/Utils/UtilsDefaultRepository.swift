//
//  File.swift
//  
//
//  Created by Gus Adi on 30/05/23.
//

import Foundation

public final class UtilsDefaultRepository: UtilsRepository {
    
    private var remote: UtilsRemoteDataSource
    
    public init(remote: UtilsRemoteDataSource = UtilsDefaultRemoteDataSource()) {
        self.remote = remote
    }
    
    public func provideGetCurrentVersion() async throws -> VersionResponse {
        try await self.remote.getCurrentVersion()
    }
}
