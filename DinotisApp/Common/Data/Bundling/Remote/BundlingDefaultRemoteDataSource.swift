//
//  BundlingDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/11/22.
//

import Foundation
import Moya
import Combine

final class BundlingDefaultRemoteDataSource: BundlingRemoteDataSource {

	private let provider: MoyaProvider<BundlingTargetType>

	init(provider: MoyaProvider<BundlingTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	func getBundlingList(query: BundlingListFilter) -> AnyPublisher<BundlingListResponse, UnauthResponse> {
		self.provider.request(.getBundlingList(query), model: BundlingListResponse.self)
	}

	func getDetailBundling(by bundleId: String) -> AnyPublisher<DetailBundlingResponse, UnauthResponse> {
		self.provider.request(.getBundlingDetail(bundleId), model: DetailBundlingResponse.self)
	}
    
    func createBundling(body: CreateBundling) -> AnyPublisher<CreateBundlingResponse, UnauthResponse> {
        self.provider.request(.createBundling(body), model: CreateBundlingResponse.self)
    }

	func updateBundling(by bundleId: String, body: UpdateBundlingBody) -> AnyPublisher<CreateBundlingResponse, UnauthResponse> {
		self.provider.request(.updateBundling(bundleId, body), model: CreateBundlingResponse.self)
	}
    
    func getAvailableMeeting() -> AnyPublisher<AvailableMeetingResponse, UnauthResponse> {
        self.provider.request(.getAvailableMeeting, model: AvailableMeetingResponse.self)
    }

	func getAvailableMeetingForEdit(with bundleId: String) -> AnyPublisher<AvailableMeetingResponse, UnauthResponse> {
		self.provider.request(.getAvailableMeetingForEdit(bundleId), model: AvailableMeetingResponse.self)
	}
    
    func deleteBundling(by bundleId: String) -> AnyPublisher<CreateBundlingResponse, UnauthResponse> {
        self.provider.request(.deleteBundling(bundleId), model: CreateBundlingResponse.self)
    }
}
