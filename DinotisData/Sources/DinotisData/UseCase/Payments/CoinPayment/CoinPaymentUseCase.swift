//
//  File.swift
//  
//
//  Created by Gus Adi on 17/02/23.
//

import Foundation

public protocol CoinPaymentUseCase {
	func execute(with request: CoinPaymentRequest) async -> Result<UserBookingData, Error>
}
