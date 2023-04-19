//
//  File.swift
//  
//
//  Created by Gus Adi on 23/02/23.
//

import Foundation

public protocol EditRateCardUseCase {
	func execute(for id: String, with params: CreateRateCardRequest) async -> Result<RateCardResponse, Error>
}
