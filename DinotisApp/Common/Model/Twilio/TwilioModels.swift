//
//  TwilioModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 23/08/22.
//

import Foundation

struct SyncRaiseHandBody: Codable {
	let userIdentity: String
	let raised: Bool

	enum CodingKeys: String, CodingKey {
		case userIdentity = "user_identity"
		case raised
	}
}

struct SyncTwilioGeneralBody: Codable {
	let userIdentity: String

	enum CodingKeys: String, CodingKey {
		case userIdentity = "user_identity"
	}
}

struct SyncMuteAllBody: Codable {
	let roomSid: String
	let lock: Bool

	enum CodingKeys: String, CodingKey {
		case roomSid = "room_sid"
		case lock
	}
}

struct SyncSpotlightSpeaker: Codable {
    let roomSid: String
    let userIdentity: String
    
    enum CodingKeys: String, CodingKey {
        case roomSid = "room_sid"
        case userIdentity = "user_identity"
    }
}

struct TwilioGeneratedTokenResponse: Codable {
	let token: String?
	let syncObjectNames: SyncObjectNames?
	let roomSid: String?
	let chatEnabled: Bool?
	let userIdentity: String?
	let joinAs: String?

	enum CodingKeys: String, CodingKey {
		case token
		case syncObjectNames = "sync_object_names"
		case roomSid = "room_sid"
		case chatEnabled = "chat_enabled"
		case userIdentity = "user_identity"
		case joinAs = "join_as"
	}
}

struct GenerateTokenTwilioType: Codable {
	let type: String
}

struct TwilioPrivateGeneratedTokenRespopnse: Codable {
    let token: String?
    let roomSid: String?
    
    enum CodingKeys: String, CodingKey {
        case token
        case roomSid = "room_sid"
    }
}

struct InvitedResponse: Codable {
	let sent: Bool?
}

struct RemovedSpeakerResponse: Codable {
	let removed: Bool?
}

struct DeletedRoomResponse: Codable {
	let deleted: Bool?
}

struct GeneralSuccessResponse: Codable {
	let success: Bool?
}
