//
//  CoinTestRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import Foundation
import Combine

public protocol CoinRemoteDataSource {
	func postVerifyCoin(receiptData: String) async throws -> SuccessResponse
	func getCoinHistory(query: GeneralParameterRequest) async throws -> CoinHistoryResponse
}
