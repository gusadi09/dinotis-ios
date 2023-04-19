//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public struct ChangePasswordRequest: Codable {
	public var oldPassword: String
	public var password: String
	public var confirmPassword: String

	public init(oldPassword: String, password: String, confirmPassword: String) {
		self.oldPassword = oldPassword
		self.password = password
		self.confirmPassword = confirmPassword
	}
}
