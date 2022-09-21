//
//  DynamicHome.swift
//  DinotisApp
//
//  Created by Gus Adi on 17/04/22.
//

import Foundation

struct DynamicHome: Codable {
	let data: [DynamicHomeData]?
	let nextCursor: Int?
}

struct DynamicHomeData: Codable {
	let id: Int?
	let name: String?
	let description: String?
	let createdAt: String?
	let updatedAt: String?
	let talentHomeTalentList: [TalentHomeData]?
}

struct TalentHomeData: Codable {
	let id: Int?
	let userId: String?
	let homeTalentListId: Int?
	let createdAt: String?
	let updatedAt: String?
	let user: Talent?
}
