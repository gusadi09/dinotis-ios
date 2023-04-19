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

struct PaymentMethodDataV1: Codable {
	var id: Int
	var code: String?
	var name: String
	var iconURL: String?
	var extraFee: Double?
	var extraFeeIsPercentage: Bool?
	var bankID: Int?
	var isEwallet, isDisbursement, isQr, isCC, isIap, isCoin, isActive, isVisible: Bool?
	
	enum CodingKeys: String, CodingKey {
		case id, code, name
		case iconURL = "iconUrl"
		case extraFee
		case bankID = "bankId"
		case isEwallet, isDisbursement, isQr, extraFeeIsPercentage, isCC, isIap, isCoin, isActive, isVisible
	}
}

typealias PaymentData = [PaymentMethod]

struct PaymentMethodResponse: Codable {
	let data: [PaymentMethodDataV1]?
}

struct BookingPay: Codable {
	var paymentMethod: Int
	var meetingId: String?
	var voucherCode: String?
    var meetingBundleId: String?
    var rateCardId: String?
}

struct ExtraFeesBody: Codable {
    var meetingId: String?
    var meetingBundleId: String?
    var rateCardId: String?
}

struct BundlingBooking: Codable {
    var paymentMethod: Int
    var voucherCode: String?
    var meetingId: String?
    var meetingBundleId: String?
}

struct CoinPay: Codable {
	var meetingId: String?
	var voucherCode: String?
    var meetingBundleId: String?
}

struct BookingData: Codable {
	var id: String
	var bookedAt: Date?
	var canceledAt: Date?
	let bookingPayment: UserBookingPayment?
}

struct Invoice: Codable {
	var id, number, status, userID, externalId: String?
	var bankID: Int?
	var expiredAt, createdAt, updatedAt: Date?
	
	enum CodingKeys: String, CodingKey {
		case id, number, status, externalId
		case userID = "userId"
		case bankID = "bankId"
		case expiredAt, createdAt, updatedAt
	}
}
