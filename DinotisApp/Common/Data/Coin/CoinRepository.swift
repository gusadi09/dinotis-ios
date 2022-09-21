//
//  CoinRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import Foundation
import Combine

protocol CoinRepository {
	func providePostVerifyCoin(with receipt: String) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func provideGetCoinHistory(by query: CoinQuery) -> AnyPublisher<CoinHistoryResponse, UnauthResponse>
}
