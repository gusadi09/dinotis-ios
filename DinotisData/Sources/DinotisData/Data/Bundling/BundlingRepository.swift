//
//  File.swift
//  
//
//  Created by Irham Naufal on 23/08/23.
//

import Foundation

public protocol BundlingRepository {
    func provideGetBundlingList(query: BundlingListFilter) async throws -> BundlingListResponse
    func provideGetDetailBundling(by bundleId: String) async throws -> DetailBundlingResponse
    func provideCreateBundling(body: CreateBundling) async throws -> CreateBundlingResponse
    func provideUpdateBundling(by bundleId: String, body: UpdateBundlingBody) async throws -> CreateBundlingResponse
    func provideGetAvailableMeeting() async throws -> AvailableMeetingResponse
    func provideGetAvailableMeetingForEdit(with bundleId: String) async throws -> AvailableMeetingResponse
    func provideDeleteBundling(by bundleId: String) async throws -> CreateBundlingResponse
}
