//
//  File.swift
//  
//
//  Created by Gus Adi on 01/02/23.
//

import Foundation

public protocol DeleteBookingsUseCase {
	func execute(by bookingId: String) async -> Result<String, Error>
}
