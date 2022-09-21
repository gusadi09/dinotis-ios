//
//  PaymentInstruction.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/01/22.
//

import Foundation

struct PaymentInstruction: Codable {
	let id: Int?
	let paymentMethod:  PaymentMethodInstruction?
	let instructions: [InstructionData]?
}

typealias InstructionResponse = [PaymentInstruction]

struct PaymentMethodInstruction: Codable {
	let id: Int?
	let name: String?
	let iconUrl: String?
	let bankId: Int?
}

struct InstructionData: Codable {
	let name: String?
	let instruction: [String]?
}
