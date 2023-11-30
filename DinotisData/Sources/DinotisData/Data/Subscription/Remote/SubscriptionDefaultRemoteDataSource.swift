//
//  File.swift
//  
//
//  Created by Gus Adi on 26/11/23.
//

import Foundation
import Moya

public final class SubscriptionDefaultRemoteDataSource: SubscriptionRemoteDataSource {
    
    private let provider: MoyaProvider<SubscriptionTargetType>
    
    public init(provider: MoyaProvider<SubscriptionTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    public func postSubscribe(userId: String, methodId: Int) async throws -> SubscriptionResponse {
        try await self.provider.request(.subscribe(userId, methodId), model: SubscriptionResponse.self)
    }
    
    public func postUnsubscribe(with userId: String) async throws -> SuccessResponse {
        try await self.provider.request(.unsubscribe(userId), model: SuccessResponse.self)
    }
}
