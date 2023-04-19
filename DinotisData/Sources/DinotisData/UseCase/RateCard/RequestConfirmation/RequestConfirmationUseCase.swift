//
//  File.swift
//  
//
//  Created by Gus Adi on 25/02/23.
//

import Foundation

public protocol RequestConfirmationUseCase {
	func execute(with id: String, contain body: ConfirmationRateCardRequest) async -> Result<SuccessResponse, Error>
}
