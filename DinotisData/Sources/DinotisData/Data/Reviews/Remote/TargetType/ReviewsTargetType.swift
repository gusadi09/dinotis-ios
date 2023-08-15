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
    case getReasons(Int?)
}

extension ReviewsTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		switch self {
		case .getReviews(_, let params):
			return params.toJSON()
        case .giveReview(let body):
            return body.toJSON()
        case .getReasons(let rating):
            guard let rating = rating else { return [:] }
            return ["rating" : rating]
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
        case .getReasons:
            return URLEncoding.queryString
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
        case .getReasons:
            return "/reviews/reasons"
        }
	}

	public var method: Moya.Method {
		switch self {
		case .getReviews(_, _):
			return .get
        case .giveReview:
            return .post
        case .getReasons:
            return .get
        }
	}

	public var sampleData: Data {
		switch self {
		case .getReviews(_, _):
			return ReviewsResponse.sampleData
        case .giveReview(_):
            return ReviewSuccessResponse.sampleData
        case .getReasons:
            return [String]().toJSONData()
        }
	}
}
