//
//  PromoCode.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/04/22.
//

import Foundation

struct PromoCodeResponse: Codable {
	let id: Int?
	let code: String?
	let amount: Int?
	let cashbackAmount: Int?
	let cashbackPercentageAmount: Int?
	let percentageAmount: Int?
	let title: String?
	let description: String?
	let isActive: Bool?
	let bookingId: String?
	let meetingId: String?
	let paymentMethodId: Int?
	let cashbackTotal: Int?
	let discountTotal: Int?
	let redeemedAt: String?
	let expiredAt: String?
	let createdAt: String?
	let updatedAt: String?
}

struct PromoCodeBody: Codable {
	let code: String
	let meetingId: String
	let paymentMethodId: Int
}

struct RedeemBody: Codable {
	let code: String
	let bookingId: String
}

struct RedeemResponse: Codable {
	let isSuccess: Bool
}
