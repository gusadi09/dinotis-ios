//
//  RateCardTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 10/11/22.
//

import Foundation
import Moya

public enum RateCardTargetType {
	case createRateCard(CreateRateCardRequest)
	case getRateCardList(GeneralParameterRequest)
	case deleteRateCard(String)
	case getDetailRateCard(String)
	case editRateCard(String, CreateRateCardRequest)
    case userGetRateCard(String, RateCardFilterRequest)
	case getMeetingRequests(RateCardFilterRequest)
    case requestSession(RequestSessionRequest)
    case paySession(RequestSessionRequest)
	case getConversationToken(String)
	case confirmRequest(String, ConfirmationRateCardRequest)
    case editRequestedSession(String, EditRequestedSessionRequest)
}

extension RateCardTargetType: DinotisTargetType, AccessTokenAuthorizable {
	public var parameters: [String : Any] {
		switch self {
		case .createRateCard(let body):
			return body.toJSON()
		case .getRateCardList(let query):
			return [
				"skip": query.skip,
				"take": query.take
			]
		case .deleteRateCard(_):
			return [:]
		case .getDetailRateCard(_):
			return [:]
		case .editRateCard(_, let body):
			return body.toJSON()
        case .userGetRateCard(_, let params):
            return [
                "skip": params.skip,
                "take": params.take
            ]
		case .getMeetingRequests(let param):
			return [
				"skip": param.skip,
				"take": param.take,
				"is_accepted": param.isAccepted,
				"is_not_confirmed": param.isNotConfirmed
			]
        case .requestSession(let body):
            return body.toJSON()
        case .paySession(let body):
            return body.toJSON()
		case .getConversationToken(_):
			return [:]
		case .confirmRequest(_, let body):
			return body.toJSON()
        case .editRequestedSession(_, let body):
            return body.toJSON()
		}
	}

	public var authorizationType: AuthorizationType? {
		return .bearer
	}

	public var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .createRateCard(_):
			return JSONEncoding.default
		case .getRateCardList(_):
			return URLEncoding.default
		case .deleteRateCard(_):
			return URLEncoding.default
		case .getDetailRateCard(_):
			return URLEncoding.default
		case .editRateCard(_, _):
			return JSONEncoding.default
        case .userGetRateCard(_, _):
            return URLEncoding.default
		case .getMeetingRequests(_):
			return URLEncoding.default
        case .requestSession(_):
            return JSONEncoding.default
        case .paySession(_):
            return JSONEncoding.default
		case .getConversationToken(_):
			return URLEncoding.default
		case .confirmRequest(_, _):
			return JSONEncoding.default
        case .editRequestedSession(_, _):
            return JSONEncoding.default
		}
	}

	public var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	public var path: String {
		switch self {
		case .createRateCard(_):
			return "/rate-cards"
		case .getRateCardList(_):
			return "/rate-cards"
		case .deleteRateCard(let id):
			return "/rate-cards/\(id)"
		case .getDetailRateCard(let id):
			return "/rate-cards/\(id)"
		case .editRateCard(let id, _):
			return "/rate-cards/\(id)"
        case .userGetRateCard(let creatorId, _):
            return "/rate-cards/\(creatorId)/talent"
		case .getMeetingRequests(_):
			return "/meeting-requests"
        case .requestSession(_):
            return "/meeting-requests"
        case .paySession(_):
            return "/meeting-requests/coin"
		case .getConversationToken(let id):
			return "/meeting-requests/\(id)/token"
		case .confirmRequest(let id, _):
			return "/meeting-requests/\(id)/confirm"
        case .editRequestedSession(let id, _):
            return "/meeting-requests/\(id)/meeting"
		}
	}

	public var method: Moya.Method {
		switch self {
		case .createRateCard(_):
			return .post
		case .getRateCardList(_):
			return .get
		case .deleteRateCard(_):
			return .delete
		case .getDetailRateCard(_):
			return .get
		case .editRateCard(_, _):
			return .put
        case .userGetRateCard(_, _):
            return .get
		case .getMeetingRequests(_):
			return .get
        case .requestSession(_):
            return .post
        case .paySession(_):
            return .post
		case .getConversationToken(_):
			return .get
		case .confirmRequest(_, _):
			return .post
        case .editRequestedSession(_, _):
            return .put
		}
	}
}
