//
//  AuthenticationHelper.swift
//  DinotisAppTest
//
//  Created by Gus Adi on 15/04/22.
//

import SwiftUI
import Moya
import Combine
@testable import DinotisApp

final class AuthenticationHelper {
	
	private let stubProvider = MoyaProvider<AuthenticationTargetType>(stubClosure: MoyaProvider.delayedStub(1.0), plugins: [NetworkLoggerPlugin()])
	
	private let endpointClosureError = { (target: AuthenticationTargetType) -> Endpoint in
		return Endpoint(
			url: URL(target: target).absoluteString,
			sampleResponseClosure: {
				.networkResponse(
					500,
					UnauthResponse(
						statusCode: 500,
						message: "Internal Server Error",
						fields: nil,
						error: "Internal Server Error"
					).toJSONData())
			},
			method: target.method,
			task: target.task,
			httpHeaderFields: target.headers
		)
	}
	
	private var errorStubProvider: MoyaProvider<AuthenticationTargetType> {
		return MoyaProvider<AuthenticationTargetType>(endpointClosure: endpointClosureError, stubClosure: MoyaProvider.immediatelyStub)
	}
	
	func stubLoginHavePassword() -> AnyPublisher<LoginResponseV2, UnauthResponse> {
		let body = LoginBodyV2(phone: "+62856783234334", role: 3, password: "1235689")
		return stubProvider.request(.login(body), model: LoginResponseV2.self)
	}
	
	func stubLoginWithoutPassword() -> AnyPublisher<LoginResponseV2, UnauthResponse> {
		let body = LoginBodyV2(phone: "+62856783234334", role: 3)
		return stubProvider.request(.login(body), model: LoginResponseV2.self)
	}
	
	func stubLoginError() -> AnyPublisher<Users, UnauthResponse> {
		let body = LoginBodyV2(phone: "+62856783234334", role: 3)
		return errorStubProvider.request(.login(body), model: Users.self)
	}
}
