//
//  SpeakersRealtimeResponse.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/10/22.
//

import Foundation

struct SpeakerRealtimeResponse: Codable, Hashable {
	let coHost: Bool?
	let host: Bool?
	let identity: String?
	let name: String?
	let photoProfile: String?
}
