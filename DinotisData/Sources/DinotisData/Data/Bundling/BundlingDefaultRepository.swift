//
//  File.swift
//  
//
//  Created by Irham Naufal on 23/08/23.
//

import Foundation

public final class BundlingDefaultRepository: BundlingRepository {
    
    private let remoteDataSource: BundlingRemoteDataSource
    
    public init(remoteDataSource: BundlingRemoteDataSource = BundlingDefaultRemoteDataSource()) {
        self.remoteDataSource = remoteDataSource
    }
    
    public func provideGetBundlingList(query: BundlingListFilter) async throws -> BundlingListResponse {
        try await remoteDataSource.getBundlingList(query: query)
    }
    
    public func provideGetDetailBundling(by bundleId: String) async throws -> DetailBundlingResponse {
        try await remoteDataSource.getDetailBundling(by: bundleId)
    }
    
    public func provideCreateBundling(body: CreateBundling) async throws -> CreateBundlingResponse {
        try await remoteDataSource.createBundling(body: body)
    }
    
    public func provideUpdateBundling(by bundleId: String, body: UpdateBundlingBody) async throws -> CreateBundlingResponse {
        try await remoteDataSource.updateBundling(by: bundleId, body: body)
    }
    
    public func provideGetAvailableMeeting() async throws -> AvailableMeetingResponse {
        try await remoteDataSource.getAvailableMeeting()
    }
    
    public func provideGetAvailableMeetingForEdit(with bundleId: String) async throws -> AvailableMeetingResponse {
        try await remoteDataSource.getAvailableMeetingForEdit(with: bundleId)
    }
    
    public func provideDeleteBundling(by bundleId: String) async throws -> CreateBundlingResponse {
        try await remoteDataSource.deleteBundling(by: bundleId)
    }
}
