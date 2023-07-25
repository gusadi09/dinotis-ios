//
//  File.swift
//  
//
//  Created by Gus Adi on 24/07/23.
//

import Foundation
import Moya

public enum DyteTargetType {
    case addParticipant(String)
}

extension DyteTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .addParticipant(_):
            return [:]
        }
    }

    public var authorizationType: AuthorizationType? {
        return .bearer
    }

    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .addParticipant(_):
            return URLEncoding.default
        }
    }

    public var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }

    public var path: String {
        switch self {
        case .addParticipant(let string):
            return "/dyte/meetings/\(string)/add-participant"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .addParticipant(_):
            return .post
        }
    }
}
