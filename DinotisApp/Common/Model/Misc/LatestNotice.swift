//
//  LatestNotice.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/05/22.
//

import Foundation

struct LatestNoticeResponse: Codable {
	let id: UInt?
	let url: String?
	let title: String?
	let description: String?
	let isActive: Bool?
	let createdAt: Date?
	let updatedAt: Date?
}

typealias LatestResponse = [LatestNoticeResponse]
