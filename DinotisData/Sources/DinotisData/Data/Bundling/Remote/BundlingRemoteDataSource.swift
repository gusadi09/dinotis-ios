//
//  File.swift
//  
//
//  Created by Irham Naufal on 23/08/23.
//

import Foundation

public protocol BundlingRemoteDataSource {
    func getBundlingList(query: BundlingListFilter) async throws -> BundlingListResponse
    func getDetailBundling(by bundleId: String) async throws -> DetailBundlingResponse
    func createBundling(body: CreateBundling) async throws -> CreateBundlingResponse
    func updateBundling(by bundleId: String, body: UpdateBundlingBody) async throws -> CreateBundlingResponse
    func getAvailableMeeting() async throws -> AvailableMeetingResponse
    func getAvailableMeetingForEdit(with bundleId: String) async throws -> AvailableMeetingResponse
    func deleteBundling(by bundleId: String) async throws -> CreateBundlingResponse
}
