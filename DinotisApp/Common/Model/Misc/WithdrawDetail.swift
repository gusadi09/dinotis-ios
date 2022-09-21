//
//  WithdrawDetail.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/10/21.
//

import Foundation

struct WithdrawDetailResponse: Codable {
	let id: String
	let amount: Int?
	let isFailed: Bool?
	let doneAt: String?
	let bankAccountId: Int?
	let balanceDetailId: Int?
	let externalId: String?
	let createdAt: String?
	let updatedAt: String?
	let bankAccount: BankAccount?
}
