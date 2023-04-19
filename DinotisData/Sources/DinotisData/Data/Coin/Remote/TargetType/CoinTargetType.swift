//
//  CoinTestTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import Foundation
import Moya

public enum CoinTargetType {
	case verifyCoin(String)
	case coinHistory(GeneralParameterRequest)
}

extension CoinTargetType: DinotisTargetType, AccessTokenAuthorizable {
	public var authorizationType: AuthorizationType? {
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

	public var path: String {
		switch self {
		case .verifyCoin:
			return "/coins/recharge/verify/ios"
		case .coinHistory:
			return "/coins/recharge/history"
		}

	}

	public var method: Moya.Method {
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

	public var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}
}
