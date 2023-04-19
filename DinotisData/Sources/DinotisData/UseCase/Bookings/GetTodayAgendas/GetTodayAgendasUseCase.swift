//
//  File.swift
//  
//
//  Created by Gus Adi on 15/02/23.
//

import Foundation

public protocol GetTodayAgendasUseCase {
	func execute() async -> Result<UserBookingsResponse, Error>
}
