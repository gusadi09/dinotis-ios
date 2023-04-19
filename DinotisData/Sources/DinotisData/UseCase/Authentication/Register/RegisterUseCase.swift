//
//  File.swift
//  
//
//  Created by Gus Adi on 25/01/23.
//

import Foundation

public protocol RegisterUseCase {
	func execute(by request: OTPRequest) async -> Result<String, Error>
}
