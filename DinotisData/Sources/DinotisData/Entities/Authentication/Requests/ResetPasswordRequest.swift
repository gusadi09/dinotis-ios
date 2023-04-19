//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public struct ResetPasswordRequest: Codable {
	public var phone: String
	public var password: String
	public var passwordConfirm: String
	public var token: String

	public init(phone: String, password: String, passwordConfirm: String, token: String) {
		self.phone = phone
		self.password = password
		self.passwordConfirm = passwordConfirm
		self.token = token
	}
}
