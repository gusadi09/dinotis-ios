//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public struct LoginRequest: Codable {
	public var phone: String
	public var role: Int
	public var password: String

	public init(phone: String, role: Int, password: String) {
		self.phone = phone
		self.role = role
		self.password = password
	}
}

public extension LoginRequest {
	func processedRequest(country: String) -> LoginRequest {
		var tempPhone = self.phone

		if self.phone.first == "0" {
			tempPhone = tempPhone.replacingCharacters(in: ...self.phone.startIndex, with: "")
		}

		let phones = "+\(country)" + tempPhone

		let body = LoginRequest(phone: phones, role: self.role, password: self.password)

		return body
	}
}
