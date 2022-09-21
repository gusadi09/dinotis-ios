//
//  QuestionTargetType.swift
//  DinotisApp
//
//  Created by Garry on 09/08/22.
//

import Foundation
import Moya

enum QuestionTargetType {
    case sendQuestion(QuestionParams)
    case getQuestion(String)
    case putQuestion(Int, QuestionBodyParam)
}

extension QuestionTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .sendQuestion(let params):
            return params.toJSON()
        case .getQuestion(_):
            return [:]
        case .putQuestion(_, let param):
            return param.toJSON()
        }
    }
    
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .getQuestion(_):
            return URLEncoding.default
        case .sendQuestion:
            return JSONEncoding.default
        case .putQuestion:
            return JSONEncoding.default
        }
    }
    
    var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }
    
    var path: String {
        switch self {
        case .getQuestion(let meetingId):
            return "/questions/\(meetingId)/meeting"
        case .sendQuestion:
            return "/questions"
        case .putQuestion(let questionId, _):
            return "/questions/\(questionId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getQuestion:
            return .get
        case .sendQuestion:
            return .post
        case .putQuestion:
            return .put
        }
    }
}
