//
//  File.swift
//  
//
//  Created by Gus Adi on 17/02/23.
//

import Foundation

public protocol BookingPaymentUseCase {
	func execute(with request: BookingPaymentRequest) async -> Result<UserBookingData, Error>
}
