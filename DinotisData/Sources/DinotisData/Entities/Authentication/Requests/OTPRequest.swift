//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public struct OTPRequest: Codable {
	public var phone: String
	public var channel: String
	public var invitationCode: String?

	public init(phone: String, channel: String = "whatsapp", invitationCode: String? = nil) {
		self.phone = phone
		self.channel = channel
		self.invitationCode = invitationCode
	}
}

public extension OTPRequest {
	func processedRequest(country: String, type: Int) -> OTPRequest {
		var tempPhone = self.phone

		if self.phone.first == "0" {
			tempPhone = tempPhone.replacingCharacters(in: ...self.phone.startIndex, with: "")
		}

		let phones = "+\(country)" + tempPhone

		let body = OTPRequest(phone: phones, channel: self.channel, invitationCode: type == 2 ? self.invitationCode : nil)

		return body
	}
}
