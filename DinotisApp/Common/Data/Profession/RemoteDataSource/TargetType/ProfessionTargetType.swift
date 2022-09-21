//
//  ProfessionTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation
import Moya

enum ProfessionTargetType {
	case getCategory
	case getProfession
	case getProfessionByCategory(Int)
}

extension ProfessionTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var authorizationType: AuthorizationType? {
		switch self {
		case .getCategory:
			return .bearer
		case .getProfession:
			return .bearer
		case .getProfessionByCategory:
			return .bearer
		}
	}
	
	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getCategory:
			return URLEncoding.default
		case .getProfession:
			return URLEncoding.default
		case .getProfessionByCategory:
			return URLEncoding.default
		}
	}
	
	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}
	
	var parameters: [String : Any] {
		switch self {
		case .getCategory:
			return [:]
		case .getProfession:
			return [:]
		case .getProfessionByCategory(let categoryID):
			return ["category": categoryID]
		}
	}
	
	var path: String {
		switch self {
		case .getCategory:
			return "/professions/categories"
		case .getProfession:
			return "/professions"
		case .getProfessionByCategory:
			return "/professions"
		}
	}
	
	var method:Moya.Method {
		switch self {
		case .getCategory:
			return .get
		case .getProfession:
			return .get
		case .getProfessionByCategory:
			return .get
		}
	}
}
