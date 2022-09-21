//
//  DinotisTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/02/22.
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
	
	var baseURL: URL {
		return URL(string: configuration.environment.baseURL) ?? (NSURL() as URL)
	}
	
	var parameterEncoding: Moya.ParameterEncoding {
		JSONEncoding.default
	}
	
	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}
	
	var headers: [String: String]? {
		return [:]
	}
}
