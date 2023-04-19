//
//  File.swift
//  
//
//  Created by Gus Adi on 02/02/23.
//

import Foundation

public struct FriendshipResponse: Codable {
	public let data: [TalentData]?
	public let nextCursor: Int?

	public init(data: [TalentData]?, nextCursor: Int?) {
		self.data = data
		self.nextCursor = nextCursor
	}
}
