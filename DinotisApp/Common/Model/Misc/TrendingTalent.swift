//
//  TrendingTalent.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/10/21.
//

import Foundation

struct TrendingTalent: Codable {
	let id: String
	let createdAt: String?
	let updatedAt: String?
	let talentId: String?
	let updatedById: String?
	let talent: TalentData
}

struct TalentData: Codable {
	let id: String
	var name: String?
	let username: String?
	let email: String?
	var profilePhoto: String?
	let profileDescription: String?
	let emailVerifiedAt: String?
	let isVerified: Bool?
	let professions: [ProfessionData]?
}

struct ProfessionData: Codable {
	let profession: ProfessionTrendingTalent
}

struct ProfessionTrendingTalent: Codable {
	let id: Int
	let name: String?
}

typealias TrendingData = [TrendingTalent]
