//
//  Message.swift
//  DinotisApp
//
//  Created by Gus Adi on 04/04/22.
//

import Foundation

struct Message: Codable {
	let id: String
	let name: String?
	let avatar: String?
	let isTalent: Bool?
	let isMe: Bool?
	let message: String?
}
