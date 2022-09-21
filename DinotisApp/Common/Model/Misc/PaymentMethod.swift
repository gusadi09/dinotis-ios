//
//  PaymentMethod.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/10/21.
//

import Foundation

struct PaymentMethod: Codable {
	var id: Int
	var code: String?
	var name: String
	var iconURL: String?
	var extraFee: Double?
	var extraFeeIsPercentage: Bool?
	var bankID: Int?
	var isEwallet, isDisbursement, isQr: Bool?
	
	enum CodingKeys: String, CodingKey {
		case id, code, name
		case iconURL = "iconUrl"
		case extraFee
		case bankID = "bankId"
		case isEwallet, isDisbursement, isQr, extraFeeIsPercentage
	}
}

struct PaymentMethodData: Codable {
	var id: Int
	var code: String?
	var name: String
	var iconURL: String?
	var extraFee: Double?
	var extraFeeIsPercentage: Bool?
	var bankID: Int?
	var isEwallet, isDisbursement, isQr: Bool?
	
	enum CodingKeys: String, CodingKey {
		case id, code, name
		case iconURL = "iconUrl"
		case extraFee
		case bankID = "bankId"
		case isEwallet, isDisbursement, isQr, extraFeeIsPercentage
	}
}

typealias PaymentData = [PaymentMethod]

struct PaymentMethodResponse: Codable {
	let data: [PaymentMethodData]?
}

struct BookingPay: Codable {
	var paymentMethod: Int
	var meetingId: String
	var voucherCode: String?
}

struct CoinPay: Codable {
	var meetingId: String
	var voucherCode: String?
}

struct BookingData: Codable {
	var id: String
	var bookedAt: String
	var canceledAt: String?
	let bookingPayment: UserBookingPayment
}

struct Invoice: Codable {
	var id, number, status, userID, externalId: String?
	var bankID: Int?
	var expiredAt, createdAt, updatedAt: String?
	
	enum CodingKeys: String, CodingKey {
		case id, number, status, externalId
		case userID = "userId"
		case bankID = "bankId"
		case expiredAt, createdAt, updatedAt
	}
}
