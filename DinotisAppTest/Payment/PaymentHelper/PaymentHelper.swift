//
//  PaymentHelper.swift
//  DinotisAppTest
//
//  Created by Gus Adi on 22/04/22.
//

import SwiftUI
import Moya
import Combine
@testable import DinotisApp

final class PaymentHelper {

	private let stubProvider = MoyaProvider<PaymentTargetType>(stubClosure: MoyaProvider.delayedStub(1.0), plugins: [NetworkLoggerPlugin()])

	private let endpointClosureError = { (target: PaymentTargetType) -> Endpoint in
		return Endpoint(
			url: URL(target: target).absoluteString,
			sampleResponseClosure: {
				.networkResponse(
					404,
					UnauthResponse(
						statusCode: 404,
						message: "Not Found",
						fields: nil,
						error: "Not Found"
					).toJSONData()
				)
			},
			method: target.method,
			task: target.task,
			httpHeaderFields: target.headers
		)
	}

	private var errorStubProvider: MoyaProvider<PaymentTargetType> {
		return MoyaProvider<PaymentTargetType>(endpointClosure: endpointClosureError, stubClosure: MoyaProvider.delayedStub(1.0))
	}

	func stubPaymentMethodFetch() -> AnyPublisher<PaymentMethodResponse, UnauthResponse> {
		return stubProvider.request(.getPaymentMethod, model: PaymentMethodResponse.self)
	}

	func stubErrorPaymentMethodFetch() -> AnyPublisher<PaymentMethodResponse, UnauthResponse> {
		return errorStubProvider.request(.getPaymentMethod, model: PaymentMethodResponse.self)
	}

	func stubGetPaymentExtraFee() -> AnyPublisher<ExtraFeeResponse, UnauthResponse> {
		return stubProvider.request(.extraFee("unitTest"), model: ExtraFeeResponse.self)
	}

	func stubErrorGetPaymentExtraFee() -> AnyPublisher<ExtraFeeResponse, UnauthResponse> {
		return errorStubProvider.request(.extraFee("unitTest"), model: ExtraFeeResponse.self)
	}

	func stubPayBooking() -> AnyPublisher<BookingData, UnauthResponse> {
		let body = BookingPay(paymentMethod: 1, meetingId: "unitTestID")
		return stubProvider.request(.payBooking(body), model: BookingData.self)
	}

	func stubErrorPayBooking() -> AnyPublisher<BookingData, UnauthResponse> {
		let body = BookingPay(paymentMethod: 1, meetingId: "unitTestID")
		return errorStubProvider.request(.payBooking(body), model: BookingData.self)
	}

	func stubCheckPromoCode(code: String) -> AnyPublisher<PromoCodeResponse, UnauthResponse> {
		let body = PromoCodeBody(code: code, meetingId: "unitest", paymentMethodId: 0)
		return stubProvider.request(.promoCodeCheck(body), model: PromoCodeResponse.self)
	}

	func stubErrorCheckPromoCode(code: String) -> AnyPublisher<PromoCodeResponse, UnauthResponse> {
		let body = PromoCodeBody(code: code, meetingId: "unitest", paymentMethodId: 0)
		return errorStubProvider.request(.promoCodeCheck(body), model: PromoCodeResponse.self)
	}
}
