//
//  File.swift
//  
//
//  Created by Gus Adi on 19/01/23.
//

import Foundation

public protocol LoginUseCase {
	func execute(by request: LoginRequest, type: UserType) async -> Result<LoginTokenData, Error>
}
