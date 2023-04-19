//
//  Participant.swift
//  DinotisApp
//
//  Created by Gus Adi on 12/10/21.
//

import Foundation

struct UserParticipant: Codable {
	var id: String
	var name: String?
	var username: String?
	var email: String?
	var password: String?
	var profilePhoto: String?
	var profileDescription: String?
	var emailVerifiedAt: Date?
	var isVerified, isPasswordFilled: Bool?
	var registeredWith: Int?
	var lastLoginAt: Date?
	let professionID: String?
	var createdAt, updatedAt: Date?
	
	enum CodingKeys: String, CodingKey {
		case id, name, username, email, password, profilePhoto, profileDescription, emailVerifiedAt, isVerified, isPasswordFilled, registeredWith, lastLoginAt
		case professionID = "professionId"
		case createdAt, updatedAt
	}
}
