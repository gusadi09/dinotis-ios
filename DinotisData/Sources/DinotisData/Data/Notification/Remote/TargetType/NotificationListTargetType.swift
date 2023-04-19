//
//  NotificationListTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/12/22.
//

import Foundation
import Moya

public enum NotificationListTargetType {
	case getNotification(NotificationRequest)
    case readAll
    case readById(String)
}

extension NotificationListTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		switch self {
		case .getNotification(let query):
			return query.toJSON()
        case .readAll:
            return [:]
        case .readById(let id):
            return [
                "id": id
            ]
        }
	}

    public var authorizationType: AuthorizationType? {
		return .bearer
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getNotification(_):
			return URLEncoding.default
        case .readAll:
            return URLEncoding.default
        case .readById(_):
            return JSONEncoding.default
		}
	}

    public var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

    public var path: String {
		switch self {
		case .getNotification(_):
			return "/notifications"
        case .readAll:
            return "/notifications/read-all"
        case .readById(_):
            return "/notifications/read"
		}
	}

    public var method: Moya.Method {
		switch self {
		case .getNotification(_):
			return .get
        case .readAll:
            return .post
        case .readById(_):
            return .post
		}
	}
}
