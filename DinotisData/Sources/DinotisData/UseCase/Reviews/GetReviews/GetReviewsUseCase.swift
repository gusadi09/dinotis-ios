//
//  File.swift
//  
//
//  Created by Gus Adi on 04/02/23.
//

import Foundation

public protocol GetReviewsUseCase {
	func execute(by talentId: String, for params: GeneralParameterRequest) async -> Result<ReviewsResponse, Error>
}
