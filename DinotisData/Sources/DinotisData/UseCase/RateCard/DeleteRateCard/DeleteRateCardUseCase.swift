//
//  File.swift
//  
//
//  Created by Gus Adi on 25/02/23.
//

import Foundation

public protocol DeleteRateCardUseCase {
	func execute(for id: String) async -> Result<SuccessResponse, Error>
}
