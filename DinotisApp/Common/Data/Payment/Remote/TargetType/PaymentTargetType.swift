//
//  PaymentTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/03/22.
//

import Foundation
import Moya

enum PaymentTargetType {
	case getPaymentMethod
	case payBooking(BookingPay)
	case payWithCoin(CoinPay)
	case extraFee(String)
	case promoCodeCheck(PromoCodeBody)
}

extension PaymentTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		switch self {
		case .getPaymentMethod:
			return [:]
		case .payBooking(let params):
			return params.toJSON()
		case .extraFee:
			return [:]
		case .promoCodeCheck(let params):
			return params.toJSON()
		case .payWithCoin(let params):
			return params.toJSON()
		}
	}
	
	var authorizationType: AuthorizationType? {
		return .bearer
	}
	
	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .payBooking:
			return JSONEncoding.default
			
		case .getPaymentMethod:
			return URLEncoding.default
			
		case .extraFee:
			return URLEncoding.default

		case .promoCodeCheck:
			return JSONEncoding.default
		case .payWithCoin:
			return JSONEncoding.default
		}
	}
	
	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}
	
	var path: String {
		switch self {
		case .getPaymentMethod:
			return "/payment-methods"
			
		case .payBooking:
			return "/bookings"
			
		case .extraFee(let id):
			return "/bookings/extra-fee/\(id)"

		case .promoCodeCheck:
			return "/voucher/check"
		case .payWithCoin:
			return "/bookings/coin"
		}
	}

	var sampleData: Data {
		switch self {
		case .getPaymentMethod:
			let response = PaymentMethodResponse(
				data: [
					PaymentMethodData(id: 1, name: "BCA"),
					PaymentMethodData(id: 2, name: "BRI")
				]
			)

			return response.toJSONData()
		case .payBooking:
			let response = BookingData(
				id: "testingid",
				bookedAt: Date().toString(format: .utc),
				bookingPayment: UserBookingPayment(
					externalId: "externalTestID",
					redirectUrl: "https://www.google.com",
					qrCodeUrl: "https://www.google.com"
				)
			)

			return response.toJSONData()
		case .extraFee:
			let response = ExtraFeeResponse(extraFee: 10000)
			return response.toJSONData()
		case .promoCodeCheck(let code):
			let response = PromoCodeResponse(
				id: 1,
				code: code.code,
				amount: 10000,
				cashbackAmount: 10000,
				cashbackPercentageAmount: 10,
				percentageAmount: 70,
				title: "testingVoucher",
				description: "testing",
				isActive: true,
				bookingId: "testBookID",
				meetingId: "testBookID",
				paymentMethodId: 10,
				cashbackTotal: 1000,
				discountTotal: 1000,
				redeemedAt: nil,
				expiredAt: Date().toString(format: .utc),
				createdAt: Date().toString(format: .utc),
				updatedAt: Date().toString(format: .utc)
			)

			return response.toJSONData()
		case .payWithCoin:
			let response = BookingData(
				id: "testingid",
				bookedAt: Date().toString(format: .utc),
				bookingPayment: UserBookingPayment(
					externalId: "externalTestID",
					redirectUrl: "https://www.google.com",
					qrCodeUrl: "https://www.google.com"
				)
			)

			return response.toJSONData()
		}
	}
	
	var method: Moya.Method {
		switch self {
		case .payBooking:
			return .post
			
		case .getPaymentMethod:
			return .get
			
		case .extraFee:
			return .post

		case .promoCodeCheck:
			return .post
		case .payWithCoin:
			return .post
		}
	}
}
