//
//  File.swift
//  
//
//  Created by Gus Adi on 23/02/23.
//

import Foundation

public protocol RequestSessionUseCase {
	func execute(with params: RequestSessionRequest) async -> Result<UserBookingData, Error>
}
