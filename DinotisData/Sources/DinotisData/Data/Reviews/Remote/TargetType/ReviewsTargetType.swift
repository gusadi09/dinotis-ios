//
//  File.swift
//  
//
//  Created by Gus Adi on 04/02/23.
//

import Foundation
import Moya

public enum ReviewsTargetType {
    case getReviewList(ReviewListFilterType)
	case getReviews(String, GeneralParameterRequest)
    case giveReview(ReviewRequestBody)
    case getReasons(Int?)
    case getTipAmounts
}

extension ReviewsTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		switch self {
        case .getReviewList(let type):
            return [
                "sort": type.value
            ]
		case .getReviews(_, let params):
			return params.toJSON()
        case .giveReview(let body):
            return body.toJSON()
        case .getReasons(let rating):
            guard let rating = rating else { return [:] }
            return ["rating" : rating]
        default:
            return [:]
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
        case .getTipAmounts:
            return URLEncoding.default
        case .getReviewList(_):
            return URLEncoding.default
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
        case .getTipAmounts:
            return "/reviews/tip-amounts"
        case .getReviewList(_):
            return "/reviews"
        }
	}

	public var method: Moya.Method {
		switch self {
        case .giveReview:
            return .post
        default:
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
        case .getTipAmounts:
            return [Int]().toJSONData()
        case .getReviewList(_):
            return InboxReviewsResponse.sampleData
        }
	}
}
