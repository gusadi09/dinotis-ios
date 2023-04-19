//
//  BundlingList.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/11/22.
//

import Foundation

struct BundlingListResponse: Codable {
	let data: [BundlingData]?
	let filters: FilterBundlingData?
	let nextCursor: Int?
}

struct BundlingData: Codable, Hashable {
	let id: String?
	let title: String?
	let description: String?
	let price: String?
	let createdAt: Date?
	let updatedAt: Date?
	let isActive: Bool?
	let session: Int?
	let isBundling: Bool?
	let isAlreadyBooked: Bool?
	let isFailed: Bool?
	let user: User?
	let meetings: [Meeting]?
    let meetingBundleId: String?
	let background: [String]?
}

struct FilterBundlingData: Codable {
	let options: [BundlingFilterOptions]?
}

struct BundlingFilterOptions: Codable, Identifiable {
	let id = UUID()
	let queries: [BundlingFilterOptionQuery]?
	let label: String?
}

struct BundlingFilterOptionQuery: Codable, Identifiable {
	let id = UUID()
	let name: String?
	let value: String?
}
