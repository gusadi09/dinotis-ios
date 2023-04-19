//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public struct SuccessResponse: Codable {
	public let message: String?

	public init(message: String?) {
		self.message = message
	}
}

public extension SuccessResponse {
	static var sampleData: Data {
		SuccessResponse(message: "Success").toJSONData()
	}

	static var sample: SuccessResponse {
		SuccessResponse(message: "Success")
	}
}
