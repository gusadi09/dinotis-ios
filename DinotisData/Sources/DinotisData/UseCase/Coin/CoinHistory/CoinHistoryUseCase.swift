//
//  File.swift
//  
//
//  Created by Gus Adi on 27/02/23.
//

import Foundation

public protocol CoinHistoryUseCase {
	func execute(by query: GeneralParameterRequest) async -> Result<CoinHistoryResponse, Error>
}
