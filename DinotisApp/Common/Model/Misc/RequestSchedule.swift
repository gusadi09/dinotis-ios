//
//  RequestSchedule.swift
//  DinotisApp
//
//  Created by Gus Adi on 23/04/22.
//

import Foundation

struct RequestScheduleResponse: Codable {
	let id: Int
	let userId: String?
	let requestUserId: String?
	let type: String?
	let createdAt: String?
	let updatedAt: String?
}

struct RequestScheduleBody: Codable {
	let requestUserId: String
	let type: String
}
