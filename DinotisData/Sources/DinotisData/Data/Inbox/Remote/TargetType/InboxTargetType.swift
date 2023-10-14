//
//  File.swift
//  
//
//  Created by Gus Adi on 13/10/23.
//

import Foundation
import Moya

public enum InboxTargetType {
    case getInboxChat(ChatInboxFilter, String)
}

extension InboxTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .getInboxChat(let filter, let query):
            return [
                "sort": filter.value,
                "query": query
            ]
        }
    }

    public var headers: [String : String]? {
        return [:]
    }

    public var authorizationType: AuthorizationType? {
        return .bearer
    }

    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .getInboxChat(_, _):
            return URLEncoding.default
        }
    }

    public var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }

    public var path: String {
        switch self {
        case .getInboxChat(_, _):
            return "/inbox"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .getInboxChat(_, _):
            return .get
        }
    }

    public var sampleData: Data {
        switch self {
        case .getInboxChat(_, _):
            return InboxChatResponse.sampleData
        }
    }
}
