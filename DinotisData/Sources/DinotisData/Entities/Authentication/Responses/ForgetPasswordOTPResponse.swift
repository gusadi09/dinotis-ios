//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public struct ForgetPasswordOTPResponse: Codable {
	public let token: String?
	public let expiresAt: String?

	public init(token: String?, expiresAt: String?) {
		self.token = token
		self.expiresAt = expiresAt
	}
}

public extension ForgetPasswordOTPResponse {
	static var sampleData: Data {
		ForgetPasswordOTPResponse(token: UUID().uuidString, expiresAt: Date().toStringFormat(with: .utc)).toJSONData()
	}

	static var sample: ForgetPasswordOTPResponse {
		ForgetPasswordOTPResponse(token: UUID().uuidString, expiresAt: Date().toStringFormat(with: .utc))
	}
}
