//
//  CoinRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import Foundation
import Combine

public protocol CoinRepository {
	func providePostVerifyCoin(with receipt: String) async throws -> SuccessResponse
	func provideGetCoinHistory(by query: GeneralParameterRequest) async throws -> CoinHistoryResponse
}
