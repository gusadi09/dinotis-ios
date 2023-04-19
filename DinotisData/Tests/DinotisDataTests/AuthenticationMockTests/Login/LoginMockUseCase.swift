//
//  File.swift
//  
//
//  Created by Gus Adi on 22/01/23.
//

import Foundation
@testable import DinotisData

final class LoginMockUseCase: LoginUseCase {
	func execute(by request: LoginRequest, type: UserType) async -> Result<LoginTokenData, Error> {
		return .success(LoginTokenData(accessToken: "mocktestaccesstoken", refreshToken: "mocktestrefreshtoken"))
	}

	func executeFailed(by request: LoginRequest, type: UserType) async -> Result<LoginTokenData, Error> {
		return .failure(ErrorResponse(statusCode: 401, message: "Unauthorized", fields: nil, error: "Unauthorized", errorCode: "UNAUTHORIZED"))
	}

	func checkPhoneNumber(by request: LoginRequest) -> String {
		return request.processedRequest(country: "62").phone
	}
}
