//
//  CoinTestRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import Foundation
import Combine

protocol CoinRemoteDataSource {
	func postVerifyCoin(receiptData: String) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func getCoinHistory(query: CoinQuery) -> AnyPublisher<CoinHistoryResponse, UnauthResponse>
}
