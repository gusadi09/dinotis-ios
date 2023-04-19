//
//  BundlingTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/11/22.
//

import Foundation
import Moya

struct BundlingListFilter: Codable {
	var take: Int = 15
	var skip: Int = 0
	var isAvailable: String = ""
}

enum BundlingTargetType {
	case getBundlingList(BundlingListFilter)
	case getBundlingDetail(String)
    case createBundling(CreateBundling)
	case updateBundling(String, UpdateBundlingBody)
    case getAvailableMeeting
    case deleteBundling(String)
	case getAvailableMeetingForEdit(String)
}

extension BundlingTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		switch self {
		case .getBundlingList(let params):
			return [
				"skip" : params.skip,
				"take" : params.take,
				"is_available" : params.isAvailable
			]
		case .getBundlingDetail(_):
			return [:]
        case .createBundling(let params):
            return params.toJSON()
		case .updateBundling(_, let params):
			return params.toJSON()
        case .getAvailableMeeting:
            return [:]
        case .deleteBundling(_):
            return [:]
		case .getAvailableMeetingForEdit(_):
			return [:]
		}
	}

	var authorizationType: AuthorizationType? {
		return .bearer
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getBundlingList(_):
			return URLEncoding.default
		case .getBundlingDetail(_):
			return URLEncoding.default
        case .createBundling(_):
            return JSONEncoding.default
		case .updateBundling(_, _):
			return JSONEncoding.default
        case .getAvailableMeeting:
            return URLEncoding.default
        case .deleteBundling(_):
            return URLEncoding.default
		case .getAvailableMeetingForEdit(_):
			return URLEncoding.default
		}
	}

	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	var path: String {
		switch self {
		case .getBundlingList(_):
			return "/meetings/bundles"
		case .getBundlingDetail(let bundleId):
			return "/meetings/bundles/\(bundleId)"
        case .createBundling(_):
            return "/meetings/bundles"
		case .updateBundling(let id, _):
			return "/meetings/bundles/\(id)"
        case .getAvailableMeeting:
            return "/meetings/bundles/available-meetings"
        case .deleteBundling(let bundleId):
            return "/meetings/bundles/\(bundleId)"
		case .getAvailableMeetingForEdit(let bundleId):
			return "/meetings/bundles/available-meetings/\(bundleId)"
		}
	}

	var method: Moya.Method {
		switch self {
		case .getBundlingList(_):
			return .get
		case .getBundlingDetail(_):
			return .get
        case .createBundling(_):
            return .post
		case .updateBundling(_, _):
			return .put
        case .getAvailableMeeting:
            return .get
        case .deleteBundling(_):
            return .delete
		case .getAvailableMeetingForEdit(_):
			return .get
		}
	}
}
