//
//  BundlingRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/11/22.
//

import Foundation
import Moya
import Combine

protocol BundlingRepository {
	func provideGetBundlingList(query: BundlingListFilter) -> AnyPublisher<BundlingListResponse, UnauthResponse>
	func provideGetDetailBundling(by bundleId: String) -> AnyPublisher<DetailBundlingResponse, UnauthResponse>
    func provideCreateBundling(body: CreateBundling) -> AnyPublisher<CreateBundlingResponse, UnauthResponse>
	func provideUpdateBundling(by bundleId: String, body: UpdateBundlingBody) -> AnyPublisher<CreateBundlingResponse, UnauthResponse>
    func provideGetAvailableMeeting() -> AnyPublisher<AvailableMeetingResponse, UnauthResponse>
	func provideGetAvailableMeetingForEdit(with bundleId: String) -> AnyPublisher<AvailableMeetingResponse, UnauthResponse>
    func provideDeleteBundling(by bundleId: String) -> AnyPublisher<CreateBundlingResponse, UnauthResponse>
}
