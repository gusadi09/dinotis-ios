//
//  Participant.swift
//  DinotisApp
//
//  Created by Gus Adi on 12/10/21.
//

import Foundation

struct ParticipantData: Codable {
	var user: Users?
	var isHost: Bool?
	let isCoHost: Bool?
}

struct UserParticipant: Codable {
	var id: String
	var name: String?
	var username: String?
	var email: String?
	var password: String?
	var profilePhoto: String?
	var profileDescription: String?
	var emailVerifiedAt: String?
	var isVerified, isPasswordFilled: Bool?
	var registeredWith: Int?
	var lastLoginAt, professionID: String?
	var createdAt, updatedAt: String?
	
	enum CodingKeys: String, CodingKey {
		case id, name, username, email, password, profilePhoto, profileDescription, emailVerifiedAt, isVerified, isPasswordFilled, registeredWith, lastLoginAt
		case professionID = "professionId"
		case createdAt, updatedAt
	}
}

typealias Participant = [ParticipantData]
