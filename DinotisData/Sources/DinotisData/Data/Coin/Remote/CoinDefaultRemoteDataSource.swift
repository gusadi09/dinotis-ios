//
//  CoinTestDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import Foundation
import Moya
import Combine

public final class CoinDefaultRemoteDataSource: CoinRemoteDataSource {

	private let provider: MoyaProvider<CoinTargetType>

	public init(provider: MoyaProvider<CoinTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	public func postVerifyCoin(receiptData: String) async throws -> SuccessResponse {
		try await self.provider.request(.verifyCoin(receiptData), model: SuccessResponse.self)
	}

	public func getCoinHistory(query: GeneralParameterRequest) async throws -> CoinHistoryResponse {
		try await self.provider.request(.coinHistory(query), model: CoinHistoryResponse.self)
	}
}
