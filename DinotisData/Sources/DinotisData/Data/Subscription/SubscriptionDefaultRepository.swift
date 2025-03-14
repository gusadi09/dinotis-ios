//
//  File.swift
//  
//
//  Created by Gus Adi on 26/11/23.
//

import Foundation

public final class SubscriptionDefaultRepository: SubscriptionRepository {
    
    private let remoteDataSource: SubscriptionRemoteDataSource
    
    public init(remoteDataSource: SubscriptionRemoteDataSource = SubscriptionDefaultRemoteDataSource()) {
        self.remoteDataSource = remoteDataSource
    }
    
    public func providePostSubscribe(userId: String, methodId: Int) async throws -> SubscriptionResponse {
        try await self.remoteDataSource.postSubscribe(userId: userId, methodId: methodId)
    }
    
    public func providePostUnsubscribe(with userId: String) async throws -> SuccessResponse {
        try await self.remoteDataSource.postUnsubscribe(with: userId)
    }
    
    public func provideGetSubscriptions(param: GeneralParameterRequest) async throws -> SubscriptionListResponse {
        try await self.remoteDataSource.getSubscriptions(param: param)
    }
}
