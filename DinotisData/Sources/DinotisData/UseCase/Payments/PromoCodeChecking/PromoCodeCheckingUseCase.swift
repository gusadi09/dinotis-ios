//
//  File.swift
//  
//
//  Created by Gus Adi on 17/02/23.
//

import Foundation

public protocol PromoCodeCheckingUseCase {
	func execute(with request: PromoCodeRequest) async -> Result<PromoCodeResponse, Error>
}
