//
//  File.swift
//  
//
//  Created by Gus Adi on 27/02/23.
//

import Foundation

public protocol CoinVerificationUseCase {
	func execute(with receiptData: String) async -> Result<SuccessResponse, Error>
}
