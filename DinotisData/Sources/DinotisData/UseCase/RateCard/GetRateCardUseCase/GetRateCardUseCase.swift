//
//  File.swift
//  
//
//  Created by Gus Adi on 25/02/23.
//

import Foundation

public protocol GetRateCardUseCase {
	func execute(with params: GeneralParameterRequest) async -> Result<RateCardListResponse, Error>
}
