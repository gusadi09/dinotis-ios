//
//  BundlingTargetType.swift
//  DinotisApp
//
//  Created by Garry on 02/11/22.
//

import Foundation
import Moya

enum BundlingTargetType {
    case createBundling(CreateBundling)
    case getMeetingList
}

extension BundlingTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .createBundling(let params):
            return params.toJSON()
        case .getMeetingList:
            return [:]
        }
    }
    
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .createBundling:
            return JSONEncoding.default
        case .getMeetingList:
            return URLEncoding.default
        }
    }
    
    var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }
    
    var path: String {
        switch self {
        case .createBundling:
            return "/meetings/bundles"
        case .getMeetingList:
            return "/meetings/bundles/available-meetings"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createBundling:
            return .post
        case .getMeetingList:
            return .get
        }
    }
}
