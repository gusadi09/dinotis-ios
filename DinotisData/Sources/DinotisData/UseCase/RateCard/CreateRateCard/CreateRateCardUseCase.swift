//
//  File.swift
//  
//
//  Created by Gus Adi on 23/02/23.
//

import Foundation

public protocol CreateRateCardUseCase {
	func execute(with params: CreateRateCardRequest) async -> Result<RateCardResponse, Error>
}
