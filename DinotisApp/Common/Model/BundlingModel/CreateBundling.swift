//
//  CreateBundling.swift
//  DinotisApp
//
//  Created by Garry on 03/11/22.
//

import Foundation

struct CreateBundling: Codable {
    let title: String
    let description: String
    let price: Int
    let meetings: [String]
}

struct UpdateBundlingBody: Codable {
	let title: String
	let description: String
	let price: Int
	let meetingIds: [String]
}

struct CreateBundlingResponse: Codable {
    let id: String?
    let title: String?
    let description: String?
    let price: String?
    let createdAt: Date?
    let updatedAt: Date?
}

struct AvailableMeetingResponse: Codable {
    let data: [Meeting]?
}
