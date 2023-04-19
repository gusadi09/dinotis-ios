//
//  CoinDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import Foundation
import Combine

public final class CoinDefaultRepository: CoinRepository {

	private let remote: CoinRemoteDataSource

	public init(remote: CoinRemoteDataSource = CoinDefaultRemoteDataSource()) {
		self.remote = remote
	}

	public func providePostVerifyCoin(with receipt: String) async throws -> SuccessResponse {
		try await self.remote.postVerifyCoin(receiptData: receipt)
	}

	public func provideGetCoinHistory(by query: GeneralParameterRequest) async throws -> CoinHistoryResponse {
		try await self.remote.getCoinHistory(query: query)
	}
}
