//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public struct OTPVerificationRequest: Codable {
	public var phone: String
	public var otp: String

	public init(phone: String, otp: String) {
		self.phone = phone
		self.otp = otp
	}
}
