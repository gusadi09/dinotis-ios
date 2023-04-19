import XCTest
@testable import DinotisData

final class AuthenticationMockTests: XCTestCase {

	private let loginUseCase = LoginMockUseCase()

    func test_success_login() async throws {
		let expectation = self.expectation(description: "loginSuccessExpect")

		let data = await loginUseCase.execute(by: LoginRequest(phone: "+62121121001", role: 3, password: "mocktest"), type: .basicUser)

		expectation.fulfill()

		await waitForExpectations(timeout: 5)

		switch data {
		case .success(let success):
			XCTAssertEqual(success.accessToken, "mocktestaccesstoken")
		case .failure(let failure as ErrorResponse):
			XCTFail(failure.message.orEmpty())
		case .failure(let failure):
			XCTFail(failure.localizedDescription)
		}
    }

	func test_failed_login() async throws {
		let expectation = self.expectation(description: "loginFailedExpect")

		let data = await loginUseCase.executeFailed(by: LoginRequest(phone: "+62121121001", role: 3, password: "mocktest"), type: .basicUser)

		expectation.fulfill()

		await waitForExpectations(timeout: 5)

		switch data {
		case .success(_):
			XCTFail("Must be failed")
		case .failure(let failure as ErrorResponse):
			XCTAssertEqual(failure.statusCode, 401)
		case .failure(_):
			XCTFail("Not expected output")
		}
	}

	func test_correct_phoneNumberRequest() async throws {
		let expectation = self.expectation(description: "correctPhoneNumberExpect")

		let data = loginUseCase.checkPhoneNumber(by: LoginRequest(phone: "08121121001", role: 3, password: "mocktest"))

		expectation.fulfill()

		await waitForExpectations(timeout: 5)

		XCTAssertEqual(data.prefix(3), "+62")
	}
}
