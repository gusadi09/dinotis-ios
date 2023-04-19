//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation
import Moya

protocol DinotisTargetType: TargetType {
	var parameters: [String: Any] {
		get
	}
}

extension DinotisTargetType {

	private var configuration: Configuration {
		return Configuration.shared
	}

	public var baseURL: URL {
		return URL(string: configuration.environment.baseURL) ?? (NSURL() as URL)
	}

	var parameterEncoding: Moya.ParameterEncoding {
		JSONEncoding.default
	}

	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	public var headers: [String: String]? {
		return [:]
	}
}
