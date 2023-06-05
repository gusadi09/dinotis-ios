//
//  File.swift
//  
//
//  Created by Gus Adi on 30/05/23.
//

import Foundation
import Moya

public enum UtilsTargetType {
    case getCurrentVersion
}

extension UtilsTargetType: DinotisTargetType, AccessTokenAuthorizable {
    public var authorizationType: AuthorizationType? {
        switch self {
        case .getCurrentVersion:
            return .none
        }
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .getCurrentVersion:
            return URLEncoding.default
        }
    }
    
    public var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }
    
    var parameters: [String : Any] {
        switch self {
        case .getCurrentVersion:
            return [ "platform" : "IOS" ]
        }
    }
    
    public var path: String {
        switch self {
        case .getCurrentVersion:
            return "/version/latest/single"
        }
    }
    
    public var method:Moya.Method {
        switch self {
        case .getCurrentVersion:
            return .get
        }
    }
}
