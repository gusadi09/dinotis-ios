//
//  File.swift
//  
//
//  Created by Gus Adi on 14/02/23.
//

import Foundation

public protocol GetBookingDetailUseCase {
	func execute(by bookingId: String) async -> Result<UserBookingData, Error>
}
