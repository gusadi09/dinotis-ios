//
//  CoinDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import Foundation
import Combine

final class CoinDefaultRepository: CoinRepository {

	let remote: CoinRemoteDataSource

	init(remote: CoinRemoteDataSource = CoinDefaultRemoteDataSource()) {
		self.remote = remote
	}

	func providePostVerifyCoin(with receipt: String) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		self.remote.postVerifyCoin(receiptData: receipt)
	}

	func provideGetCoinHistory(by query: CoinQuery) -> AnyPublisher<CoinHistoryResponse, UnauthResponse> {
		self.remote.getCoinHistory(query: query)
	}
}
