//
//  Friendship.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/12/22.
//

import Foundation

struct FriendshipResponse: Codable {
	let data: [TalentFriendshipData]?
	let nextCursor: Int?
}

struct TalentFriendshipData: Codable, Hashable {
	static func == (lhs: TalentFriendshipData, rhs: TalentFriendshipData) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	let id: String
	var name: String?
	let username: String?
	let email: String?
	var profilePhoto: String?
	let profileDescription: String?
	let emailVerifiedAt: Date?
	let isVerified: Bool?
	let professions: [String]?
}
