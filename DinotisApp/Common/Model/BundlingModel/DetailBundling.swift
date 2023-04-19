//
//  DetailBundling.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/11/22.
//

import Foundation
import DinotisData

struct DetailBundlingResponse: Codable {
	let id: String?
	let title: String?
	let description: String?
	let price: String?
    let user: UserResponse?
	let createdAt: Date?
	let updatedAt: Date?
	let meetings: [Meeting]?
}

