//
//  TalentTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/02/22.
//

import Foundation
import Moya

public enum TalentTargetType {
	case getCrowdedTalent(TalentsRequest)
	case getRecommendationTalent(TalentsRequest)
	case getSearchedTalent(TalentsRequest)
	case getTalentDetail(String)
	case sendRequestSchedule(String, SendScheduleRequest)
}

extension TalentTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .getCrowdedTalent(let query):
            return query.toJSON()
        case .getRecommendationTalent:
            return [:]
        case .getSearchedTalent(let query):
            return query.toJSON()
        case .getTalentDetail:
            return [:]
        case .sendRequestSchedule(_, let body):
            return body.toJSON()
        }
    }
    
    public var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .getSearchedTalent:
            return URLEncoding.queryString
        case .getRecommendationTalent:
            return URLEncoding.queryString
        case .getCrowdedTalent:
            return URLEncoding.queryString
        case .getTalentDetail:
            return URLEncoding.queryString
				case .sendRequestSchedule(_, _):
					return JSONEncoding.default
				}
    }
    
    public var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }
    
    public var path: String {
        switch self {
        case .getCrowdedTalent:
            return "/talents/trending"
        case .getRecommendationTalent:
            return "/talents/recommendation"
        case .getSearchedTalent:
			return "/talents"
		case .getTalentDetail(let username):
			return "/talents/\(username)/user"
		case .sendRequestSchedule(let talentId, _):
			return "/users/request/schedule/\(talentId)"
		}
	}
	
    public var sampleData: Data {
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
						createdAt: Date(),
						updatedAt: Date()
					)

					return response.toJSONData()
				}
    }
    
    public var method: Moya.Method {
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
