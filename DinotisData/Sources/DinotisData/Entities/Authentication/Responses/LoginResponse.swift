//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public struct LoginTokenData: Codable {
	public let accessToken: String?
	public let refreshToken: String?

	public init(accessToken: String?, refreshToken: String?) {
		self.accessToken = accessToken
		self.refreshToken = refreshToken
	}
}

public struct LoginResponse: Codable {
	public let data: LoginData?
	public let token: LoginTokenData?

	public init(data: LoginData?, token: LoginTokenData?) {
		self.data = data
		self.token = token
	}
}

public extension LoginResponse {
	static var sample: LoginResponse {
		LoginResponse(
			data: LoginData(
				phone: "+62121121001",
				isDataFilled: true,
				isPasswordFilled: true
			),
			token: LoginTokenData(
				accessToken: UUID().uuidString,
				refreshToken: UUID().uuidString
			)
		)
	}

	static var sampleData: Data {
		LoginResponse(
			data: LoginData(
				phone: "+62121121001",
				isDataFilled: true,
				isPasswordFilled: true
			),
			token: LoginTokenData(
				accessToken: UUID().uuidString,
				refreshToken: UUID().uuidString
			)
		).toJSONData()
	}
}

public extension LoginTokenData {
	static var sampleData: Data {
		LoginTokenData(accessToken: UUID().uuidString, refreshToken: UUID().uuidString).toJSONData()
	}

	static var sample: LoginTokenData {
		LoginTokenData(accessToken: UUID().uuidString, refreshToken: UUID().uuidString)
	}
}

public struct LoginData: Codable {
	public let phone: String?
	public let isDataFilled: Bool?
	public let isPasswordFilled: Bool?

	public init(phone: String?, isDataFilled: Bool?, isPasswordFilled: Bool?) {
		self.phone = phone
		self.isDataFilled = isDataFilled
		self.isPasswordFilled = isPasswordFilled
	}
}
