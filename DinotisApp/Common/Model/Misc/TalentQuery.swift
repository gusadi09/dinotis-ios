//
//  TalentQuery.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/03/22.
//

import Foundation

struct TalentQueryParams: Codable {
	var query: String
	var skip: Int
	var take: Int
	var profession: Int?
	var professionCategory: Int?
}
