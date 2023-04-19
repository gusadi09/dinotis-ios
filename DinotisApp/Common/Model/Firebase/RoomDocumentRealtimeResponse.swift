//
//  RoomDocumentRealtimeResponse.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/10/22.
//

import Foundation

struct RoomDocumentRealtimeResponse: Codable {
	let micDisabled: Bool?
	let qnaSent: Bool?
	let spotlightedParticipant: String?
}
