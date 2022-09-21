//
//  Banner.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/04/22.
//

import Foundation

struct BannerData: Codable {
	let data: [Banner]?
}

struct Banner: Codable {
	let id: Int?
	let title: String?
	let url: String?
	let imgUrl: String?
	let caption: String?
	let description: String?
	let createdAt: String?
	let updatedAt: String?
}
