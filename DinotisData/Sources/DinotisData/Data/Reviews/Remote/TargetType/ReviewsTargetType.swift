//
//  File.swift
//  
//
//  Created by Gus Adi on 04/02/23.
//

import Foundation
import Moya

public enum ReviewsTargetType {
	case getReviews(String, GeneralParameterRequest)
    case giveReview(ReviewRequestBody)
}

extension ReviewsTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		switch self {
		case .getReviews(_, let params):
			return params.toJSON()
        case .giveReview(let body):
            return body.toJSON()
        }
	}

	public var headers: [String : String]? {
		return [:]
	}

	public var authorizationType: AuthorizationType? {
		return .bearer
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getReviews(_, _):
			return URLEncoding.default
        case .giveReview:
            return JSONEncoding.default
        }
	}

	public var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	public var path: String {
		switch self {
		case .getReviews(let talentId, _):
			return "/reviews/\(talentId)/creator"
        case .giveReview(_):
            return "/reviews"
        }
	}

	public var method: Moya.Method {
		switch self {
		case .getReviews(_, _):
			return .get
        case .giveReview:
            return .post
        }
	}

	public var sampleData: Data {
		switch self {
		case .getReviews(_, _):
			return ReviewsResponse.sampleData
        case .giveReview(_):
            return ReviewSuccessResponse.sampleData
        }
	}
}
