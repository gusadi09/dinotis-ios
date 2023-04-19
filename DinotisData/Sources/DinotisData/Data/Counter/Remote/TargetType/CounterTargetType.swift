//
//  File.swift
//  
//
//  Created by Gus Adi on 21/03/23.
//

import Foundation
import Moya

public enum CounterTargetType {
    case getCounter
}

extension CounterTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .getCounter:
            return [:]
        }
    }

    public var authorizationType: AuthorizationType? {
        return .bearer
    }

    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .getCounter:
            return URLEncoding.default
        }
    }

    public var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }

    public var path: String {
        switch self {
        case .getCounter:
            return "/counters"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .getCounter:
            return .get
        }
    }
}
