//
//  PaymentTests.swift
//  DinotisAppTest
//
//  Created by Gus Adi on 22/04/22.
//

import XCTest
import Moya
import Combine
@testable import DinotisApp

class PaymentTests: XCTestCase {

	private let paymentStub = PaymentHelper()
	private var cancellables = Set<AnyCancellable>()

	func test_successFetch_paymentMethod() throws {
		paymentStub.stubPaymentMethodFetch()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTFail(error.message.orEmpty())

				case .finished:
					break
				}
			} receiveValue: { value in
				XCTAssertNotEqual((value.data?.count).orZero(), 0)
			}
			.store(in: &cancellables)
	}

	func test_errorFetch_paymentMethod() throws {
		paymentStub.stubErrorPaymentMethodFetch()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTAssertEqual(error.statusCode.orZero(), 404)

				case .finished:
					break
				}
			} receiveValue: { _ in
				XCTFail("Not expected result")
			}
			.store(in: &cancellables)
	}

	func test_successPayment_booking() throws {
		paymentStub.stubPayBooking()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTFail(error.message.orEmpty())

				case .finished:
					break
				}
			} receiveValue: { value in
				XCTAssertNotNil(value.bookingPayment.externalId)
			}
			.store(in: &cancellables)
	}

	func test_failedPayment_booking() throws {
		paymentStub.stubErrorPayBooking()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTAssertEqual(error.statusCode.orZero(), 404)

				case .finished:
					break
				}
			} receiveValue: { _ in
				XCTFail("Not expected result")
			}
			.store(in: &cancellables)
	}

	func test_success_getExtraFee() throws {
		paymentStub.stubGetPaymentExtraFee()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTFail(error.message.orEmpty())

				case .finished:
					break
				}
			} receiveValue: { value in
				XCTAssertEqual(value.extraFee.orZero(), 10000)
			}
			.store(in: &cancellables)
	}

	func test_failed_getExtraFee() throws {
		paymentStub.stubErrorGetPaymentExtraFee()
			.sink { result in
				switch result {
				case .failure(let error):
					XCTAssertEqual(error.statusCode.orZero(), 404)

				case .finished:
					break
				}
			} receiveValue: { _ in
				XCTFail("Not expected result")
			}
			.store(in: &cancellables)
	}

	func test_available_promoCode() throws {
		let code = "UNITTEST"

		paymentStub.stubCheckPromoCode(code: code)
			.sink { result in
				switch result {
				case .failure(let error):
					XCTFail(error.message.orEmpty())

				case .finished:
					break
				}
			} receiveValue: { value in
				XCTAssertEqual(value.code, code)
			}
			.store(in: &cancellables)
	}

	func test_notAvailable_promoCode() throws {
		let code = "UNITTEST"

		paymentStub.stubErrorCheckPromoCode(code: code)
			.sink { result in
				switch result {
				case .failure(let error):
					XCTAssertEqual(error.statusCode.orZero(), 404)

				case .finished:
					break
				}
			} receiveValue: { _ in
				XCTFail("Not expected result")
			}
			.store(in: &cancellables)
	}

}
