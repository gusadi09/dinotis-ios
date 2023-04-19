//
//  TrendingTalent.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/10/21.
//

import Foundation
import DinotisData

struct TrendingTalent: Codable {
	let id: String
	let createdAt: Date?
	let updatedAt: Date?
	let talentId: String?
	let updatedById: String?
	let talent: TalentData
}

struct ProfessionTrendingTalent: Codable {
	let id: Int
	let name: String?
}

typealias TrendingData = [TrendingTalent]
