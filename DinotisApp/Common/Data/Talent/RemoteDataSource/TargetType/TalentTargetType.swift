//
//  TalentTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/02/22.
//

import Foundation
import Moya

enum TalentTargetType {
	case getCrowdedTalent(TalentQueryParams)
	case getRecommendationTalent(TalentQueryParams)
	case getSearchedTalent(TalentQueryParams)
	case getTalentDetail(String)
	case sendRequestSchedule(String, RequestScheduleBody)
}

extension TalentTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .getCrowdedTalent(let query):
            return [
                "profession": query.profession == 0 || query.profession == nil ? "" : query.profession.orZero(),
                "profession_category": query.professionCategory == 0 || query.professionCategory == nil ? "" : query.professionCategory.orZero()
            ]
        case .getRecommendationTalent:
            return [:]
        case .getSearchedTalent(let query):
            return [
                "query": query.query,
                "skip": query.skip == 0 ? "" : query.skip,
                "take": query.take == 0 ? "" : query.take,
                "profession": query.profession == 0 || query.profession == nil ? "" : query.profession.orZero(),
                "profession_category": query.professionCategory == 0 || query.professionCategory == nil ? "" : query.professionCategory.orZero()
            ]
        case .getTalentDetail:
            return [:]
				case .sendRequestSchedule(_, let body):
					return body.toJSON()
				}
    }
    
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .getSearchedTalent:
            return URLEncoding.default
        case .getRecommendationTalent:
            return URLEncoding.default
        case .getCrowdedTalent:
            return URLEncoding.default
        case .getTalentDetail:
            return URLEncoding.default
				case .sendRequestSchedule(_, _):
					return JSONEncoding.default
				}
    }
    
    var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }
    
    var path: String {
        switch self {
        case .getCrowdedTalent:
            return "/talents/trending"
        case .getRecommendationTalent:
            return "/talents/recommendation"
        case .getSearchedTalent:
            return "/talents"
        case .getTalentDetail(let username):
            return "/talents/\(username)"
				case .sendRequestSchedule(let talentId, _):
					return "/users/request/schedule/\(talentId)"
				}
    }
    
    var sampleData: Data {
        switch self {
        case .getCrowdedTalent(_):
            return Data()
        case .getRecommendationTalent(_):
            return Data()
        case .getSearchedTalent(_):
            return Data()
        case .getTalentDetail(_):
            return Data()
				case .sendRequestSchedule(let talentId, let body):
					let response = RequestScheduleResponse(
						id: 1,
						userId: talentId,
						requestUserId: body.requestUserId,
						type: body.type,
						createdAt: Date().toString(format: .utc),
						updatedAt: Date().toString(format: .utc)
					)

					return response.toJSONData()
				}
    }
    
    var method: Moya.Method {
			switch self {
			case .getCrowdedTalent:
				return .get
			case .getRecommendationTalent:
				return .get
			case .getSearchedTalent:
				return .get
			case .getTalentDetail:
				return .get
			case .sendRequestSchedule:
				return .post
			}
    }
}
