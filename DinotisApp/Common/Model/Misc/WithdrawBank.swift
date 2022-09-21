//
//  WithdrawBank.swift
//  DinotisApp
//
//  Created by Gus Adi on 27/10/21.
//

import Foundation

struct Bank: Codable {
	let id: Int?
	let name: String?
	let iconUrl: String?
	let xenditCode: String?
	let createdAt: String?
	let updatedAt: String?
}

typealias BankResponse = [Bank]
