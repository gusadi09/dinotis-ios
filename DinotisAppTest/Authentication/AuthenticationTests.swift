//
//  DinotisAppTest.swift
//  DinotisAppTest
//
//  Created by Gus Adi on 28/10/21.
//

import XCTest
import Moya
import Combine
@testable import DinotisApp

class AuthenticationTests: XCTestCase {
	
	private let authenticationStub = AuthenticationHelper()
	private var cancellables = Set<AnyCancellable>()
	
	func test_successLogin_showPassword() throws {
		authenticationStub.stubLoginWithoutPassword()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTFail(error.message.orEmpty())
					
				case .finished:
					break
				}
			} receiveValue: { value in
				XCTAssertEqual(value.data?.isPasswordFilled, false)
			}
			.store(in: &cancellables)
	}
	
	func test_successLogin_getToken() throws {
		authenticationStub.stubLoginHavePassword()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTFail(error.message.orEmpty())
					
				case .finished:
					break
				}
			} receiveValue: { value in
				XCTAssertEqual(value.token?.accessToken.isEmpty, false)
			}
			.store(in: &cancellables)
	}
	
	func test_internal_server_error_login() throws {
		authenticationStub.stubLoginError()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTAssertEqual(500, error.statusCode.orZero())
					
				case .finished:
					break
				}
			} receiveValue: { _ in
				XCTFail("Unexpected result")
			}
			.store(in: &cancellables)
	}
}
