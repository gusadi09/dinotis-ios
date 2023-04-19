//
//  File.swift
//  
//
//  Created by Gus Adi on 23/02/23.
//

import Foundation

public protocol DetailRateCardUseCase {
	func execute(for id: String) async -> Result<RateCardResponse, Error>
}
