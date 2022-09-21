//
//  Categories.swift
//  DinotisApp
//
//  Created by Gus Adi on 27/02/22.
//

import Foundation

struct CategoriesResponse: Codable {
	let data: [Categories]?
	let nextCursor: Int?
}

struct Categories: Codable, Identifiable {
	let id: Int?
	let name: String?
	let icon: String?
	let professions: [CategoriesProfession]?
	let createdAt: String?
	let updatedAt: String?
}

struct CategoriesProfession: Codable {
	let id: Int?
	let name: String?
	let professionCategoryId: Int?
	let professionCategory: String?
	let createdAt: String?
	let updatedAt: String?
}
