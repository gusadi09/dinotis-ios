//
//  File.swift
//  
//
//  Created by Gus Adi on 30/05/23.
//

import Foundation
import Moya

public final class UtilsDefaultRemoteDataSource: UtilsRemoteDataSource {
    
    private var provider: MoyaProvider<UtilsTargetType>
    
    public init(provider: MoyaProvider<UtilsTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    public func getCurrentVersion() async throws -> VersionResponse {
        try await self.provider.request(.getCurrentVersion, model: VersionResponse.self)
    }
}
