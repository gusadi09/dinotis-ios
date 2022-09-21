//
//  CoinTestTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import Foundation
import Moya

enum CoinTargetType {
	case verifyCoin(String)
	case coinHistory(CoinQuery)
}

extension CoinTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var authorizationType: AuthorizationType? {
		return .bearer
	}

	var parameters: [String: Any] {
		switch self {
		case .verifyCoin(let string):
			return ["receipt-data": string]
		case .coinHistory(let query):
			return [
				"skip": query.skip,
				"take": query.take
			]
		}

	}

	var path: String {
		switch self {
		case .verifyCoin:
			return "/coins/recharge/verify/ios"
		case .coinHistory:
			return "/coins/recharge/history"
		}

	}

	var method: Moya.Method {
		switch self {
		case .verifyCoin:
			return .post
		case .coinHistory:
			return .get
		}
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .verifyCoin:
			return JSONEncoding.default
		case .coinHistory:
			return URLEncoding.default
		}
	}

	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}
}
