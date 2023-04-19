//
//  BundlingRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/11/22.
//

import Foundation
import Moya
import Combine

protocol BundlingRemoteDataSource {
	func getBundlingList(query: BundlingListFilter) -> AnyPublisher<BundlingListResponse, UnauthResponse>
	func getDetailBundling(by bundleId: String) -> AnyPublisher<DetailBundlingResponse, UnauthResponse>
    func createBundling(body: CreateBundling) -> AnyPublisher<CreateBundlingResponse, UnauthResponse>
	func updateBundling(by bundleId: String, body: UpdateBundlingBody) -> AnyPublisher<CreateBundlingResponse, UnauthResponse>
    func getAvailableMeeting() -> AnyPublisher<AvailableMeetingResponse, UnauthResponse>
	func getAvailableMeetingForEdit(with bundleId: String) -> AnyPublisher<AvailableMeetingResponse, UnauthResponse>
    func deleteBundling(by bundleId: String) -> AnyPublisher<CreateBundlingResponse, UnauthResponse>
}
