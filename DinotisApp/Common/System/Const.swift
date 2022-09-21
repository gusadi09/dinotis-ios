//
//  Const.swift
//  DinotisApp
//
//  Created by Gus Adi on 08/08/21.
//

import Foundation

enum UserType: Int {
	case basicUser = 3
	case talent = 2
}

enum HMError: Error {
	case clientError(code: Int, message: String)
	case serverError(code: Int, message: String)
	case custom(message: String)
}

extension HMError {
	public var errorDescription: String? {
		switch self {
		case let .clientError(code, message):
			return "\(message) (errorcode: \(code))"
		case let .serverError(code, message):
			return "\(message) (errorcode: \(code))"
		case let .custom(message):
			return message
		}
	}
}
