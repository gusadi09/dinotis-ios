//
//  File.swift
//  
//
//  Created by Irham Naufal on 23/08/23.
//

import Foundation
import Moya

public final class BundlingDefaultRemoteDataSource: BundlingRemoteDataSource {
    
    private let provider: MoyaProvider<BundlingTargetType>
    
    public init(provider: MoyaProvider<BundlingTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    public func getBundlingList(query: BundlingListFilter) async throws -> BundlingListResponse {
        try await provider.request(.getBundlingList(query), model: BundlingListResponse.self)
    }
    
    public func getDetailBundling(by bundleId: String) async throws -> DetailBundlingResponse {
        try await provider.request(.getBundlingDetail(bundleId), model: DetailBundlingResponse.self)
    }
    
    public func createBundling(body: CreateBundling) async throws -> CreateBundlingResponse {
        try await provider.request(.createBundling(body), model: CreateBundlingResponse.self)
    }
    
    public func updateBundling(by bundleId: String, body: UpdateBundlingBody) async throws -> CreateBundlingResponse {
        try await provider.request(.updateBundling(bundleId, body), model: CreateBundlingResponse.self)
    }
    
    public func getAvailableMeeting() async throws -> AvailableMeetingResponse {
        try await provider.request(.getAvailableMeeting, model: AvailableMeetingResponse.self)
    }
    
    public func getAvailableMeetingForEdit(with bundleId: String) async throws -> AvailableMeetingResponse {
        try await provider.request(.getAvailableMeetingForEdit(bundleId), model: AvailableMeetingResponse.self)
    }
    
    public func deleteBundling(by bundleId: String) async throws -> CreateBundlingResponse {
        try await provider.request(.deleteBundling(bundleId), model: CreateBundlingResponse.self)
    }
}
