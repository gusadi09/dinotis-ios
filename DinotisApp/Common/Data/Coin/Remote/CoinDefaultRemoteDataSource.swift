//
//  CoinTestDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import Foundation
import Moya
import Combine

final class CoinDefaultRemoteDataSource: CoinRemoteDataSource {

	let provider: MoyaProvider<CoinTargetType>

	init(provider: MoyaProvider<CoinTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	func postVerifyCoin(receiptData: String) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		self.provider.request(.verifyCoin(receiptData), model: SuccessResponse.self)
	}

	func getCoinHistory(query: CoinQuery) -> AnyPublisher<CoinHistoryResponse, UnauthResponse> {
		self.provider.request(.coinHistory(query), model: CoinHistoryResponse.self)
	}
}
