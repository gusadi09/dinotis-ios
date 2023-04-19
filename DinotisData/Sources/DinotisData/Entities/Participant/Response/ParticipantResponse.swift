//
//  File.swift
//  
//
//  Created by Gus Adi on 01/02/23.
//

import Foundation

public struct ParticipantData: Codable {
	public let user: UserResponse?
	public let isHost: Bool?
	public let isCoHost: Bool?
}

public typealias ParticipantResponse = [ParticipantData]

public extension ParticipantData {
	static var sample: ParticipantData {
		ParticipantData(
			user: UserResponse.sample,
			isHost: false,
			isCoHost: false
		)
	}

	static var sampleData: Data {
		ParticipantData(
			user: UserResponse.sample,
			isHost: false,
			isCoHost: false
		).toJSONData()
	}

	static var sampleResponse: [ParticipantData] {
		[
			self.sample
		]
	}

	static var sampleResponseData: Data {
		[
			self.sample
		].toJSONData()
	}
}
