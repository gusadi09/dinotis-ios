//
//  HomeTests.swift
//  DinotisAppTest
//
//  Created by Gus Adi on 16/04/22.
//

import XCTest
import Moya
import Combine
@testable import DinotisApp

class HomeTests: XCTestCase {
	
	private let homeStub = HomeHelper()
	private var cancellables = Set<AnyCancellable>()
	
	func test_get_first_banner_success() throws {
		homeStub.stubGetFirstBanner()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTFail(error.message.orEmpty())
					
				case .finished:
					break
				}
			} receiveValue: { value in
				XCTAssertEqual((value.data?.first?.id).orZero(), 1)
			}
			.store(in: &cancellables)
	}
	
	func test_get_second_banner_success() throws {
		homeStub.stubGetSecondBanner()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTFail(error.message.orEmpty())
					
				case .finished:
					break
				}
			} receiveValue: { value in
				XCTAssertEqual((value.data?.first?.id).orZero(), 1)
			}
			.store(in: &cancellables)
	}
	
	func test_error_unauthorized_first_banner() throws {
		homeStub.errorStubFirstBanner()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTAssertEqual(401, error.statusCode.orZero())
					
				case .finished:
					break
				}
			} receiveValue: { _ in
				XCTFail("Unexpected result")
			}
			.store(in: &cancellables)
	}
	
	func test_error_unauthorized_second_banner() throws {
		homeStub.errorStubSecondBanner()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTAssertEqual(401, error.statusCode.orZero())
					
				case .finished:
					break
				}
			} receiveValue: { _ in
				XCTFail("Unexpected result")
			}
			.store(in: &cancellables)
	}
	
	func test_get_dynamicHomeList_success() throws {
		homeStub.stubGetHomeDynamicList()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTFail(error.message.orEmpty())
					
				case .finished:
					break
				}
			} receiveValue: { value in
				XCTAssertEqual((value.data?.count).orZero(), 1)
			}
			.store(in: &cancellables)
	}
	
	func test_error_unauthorized_dynamicHomeList() throws {
		homeStub.errorStubHomeDynamicList()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTAssertEqual(401, error.statusCode.orZero())
					
				case .finished:
					break
				}
			} receiveValue: { _ in
				XCTFail("Unexpected result")
			}
			.store(in: &cancellables)
	}

	func test_get_announcement_success() throws {
		homeStub.stubGetAnnouncement()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTFail(error.message.orEmpty())

				case .finished:
					break
				}
			} receiveValue: { value in
				XCTAssertEqual((value.data?.count).orZero(), 1)
			}
			.store(in: &cancellables)
	}

	func test_error_unauthorized_announcement() throws {
		homeStub.errorStubGetAnnouncement()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTAssertEqual(401, error.statusCode.orZero())

				case .finished:
					break
				}
			} receiveValue: { _ in
				XCTFail("Unexpected result")
			}
			.store(in: &cancellables)
	}
}
