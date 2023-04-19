//
//  BundlingDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/11/22.
//

import Foundation
import Combine

final class BundlingDefaultRepository: BundlingRepository {

	private let remoteDataSource: BundlingRemoteDataSource

	init(remoteDataSource: BundlingRemoteDataSource = BundlingDefaultRemoteDataSource()) {
		self.remoteDataSource = remoteDataSource
	}

	func provideGetBundlingList(query: BundlingListFilter) -> AnyPublisher<BundlingListResponse, UnauthResponse> {
		self.remoteDataSource.getBundlingList(query: query)
	}

	func provideGetDetailBundling(by bundleId: String) -> AnyPublisher<DetailBundlingResponse, UnauthResponse> {
		self.remoteDataSource.getDetailBundling(by: bundleId)
	}
    
    func provideCreateBundling(body: CreateBundling) -> AnyPublisher<CreateBundlingResponse, UnauthResponse> {
        self.remoteDataSource.createBundling(body: body)
    }

	func provideUpdateBundling(by bundleId: String, body: UpdateBundlingBody) -> AnyPublisher<CreateBundlingResponse, UnauthResponse> {
		self.remoteDataSource.updateBundling(by: bundleId, body: body)
	}
    
    func provideGetAvailableMeeting() -> AnyPublisher<AvailableMeetingResponse, UnauthResponse> {
        self.remoteDataSource.getAvailableMeeting()
    }

	func provideGetAvailableMeetingForEdit(with bundleId: String) -> AnyPublisher<AvailableMeetingResponse, UnauthResponse> {
		self.remoteDataSource.getAvailableMeetingForEdit(with: bundleId)
	}
    
    func provideDeleteBundling(by bundleId: String) -> AnyPublisher<CreateBundlingResponse, UnauthResponse> {
        self.remoteDataSource.deleteBundling(by: bundleId)
    }
}
