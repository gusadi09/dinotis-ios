//
//  PromoCode.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/04/22.
//

import Foundation

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
