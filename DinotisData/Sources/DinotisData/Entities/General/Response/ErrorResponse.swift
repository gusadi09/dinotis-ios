//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public struct ErrorResponse: Codable, Error {
	public let statusCode: Int?
	public let message: String?
	public let fields: [FieldError]?
	public let error: String?
	public let errorCode: String?

	public init(statusCode: Int?, message: String?, fields: [FieldError]?, error: String?, errorCode: String?) {
		self.statusCode = statusCode
		self.message = message
		self.fields = fields
		self.error = error
		self.errorCode = errorCode
	}
}

public struct FieldError: Codable {
	public let id: String?
	public let name: String?
	public let error: String?

	public init(id: String?, name: String?, error: String?) {
		self.id = id
		self.name = name
		self.error = error
	}
}
