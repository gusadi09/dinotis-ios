//
//  File.swift
//  
//
//  Created by Gus Adi on 14/02/23.
//

import Foundation

public protocol GetUserBookingsUseCase {
	func execute(with query: UserBookingQueryParam) async -> Result<UserBookingsResponse, Error>
}
