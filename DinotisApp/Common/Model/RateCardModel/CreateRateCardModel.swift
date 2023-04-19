//
//  CreateRateCardModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 10/11/22.
//

import Foundation

struct RateCardBodyParams: Codable {
	let title: String
	let description: String
	let duration: Int
	let price: Int
}

struct RequestSessionBody: Codable {
    var paymentMethod: Int?
    var rateCardId: String
    var message: String
    var voucherCode: String?
}

struct RequestSessionResponse: Codable {
    let id: String?
    let message: String?
    let isAccepted: Bool?
    let rateCardId: String?
    let meetingId: String?
    let userId: String?
    let createdAt: Date?
    let updatedAt: Date?
}

struct EditRequestedSessionBody: Codable {
    let startAt: String
    let endAt: String
}
