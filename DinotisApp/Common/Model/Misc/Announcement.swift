//
//  Announcement.swift
//  DinotisApp
//
//  Created by Gus Adi on 25/04/22.
//

import Foundation

struct AnnouncementResponse: Codable {
	let data: [AnnouncementData]?
	let nextCursor: Int?
}

struct AnnouncementData: Codable {
	let id: Int?
	let title: String?
	let imgUrl: String?
	let url: String?
	let caption: String?
	let description: String?
	let createdAt: String?
	let updatedAt: String?
	var showing: Bool? = true

	static func == (lhs: AnnouncementData, rhs: AnnouncementData) -> Bool {
		lhs.id.orZero() == rhs.id.orZero()
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.orZero())
	}
}
