//
//  File.swift
//  
//
//  Created by Gus Adi on 25/02/23.
//

import Foundation

public protocol GetAudienceRateCardUseCase {
	func execute(for id: String, with params: RateCardFilterRequest) async -> Result<RateCardListResponse, Error>
}
