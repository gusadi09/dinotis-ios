//
//  File.swift
//  
//
//  Created by mora hakim on 07/08/23.
//

import Foundation
import Moya

public enum QuestionTargetType {
    case sendQuestion(QuestionRequest)
    case getQuestion(String)
    case putQuestion(Int, AnsweredRequest)
}

 extension QuestionTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .sendQuestion(let sendQuestionParams):
            return sendQuestionParams.toJSON()
        case .getQuestion(_):
            return [:]
        case .putQuestion(_, let putQuestionParams):
            return putQuestionParams.toJSON()
        }
    }
    
    public var authorizationType: AuthorizationType? {
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
    
    public var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }
    
    public var path: String {
        switch self {
        case .getQuestion(let meetingId):
            return "/questions/\(meetingId)/meeting"
        case .sendQuestion:
            return "/questions"
        case .putQuestion(let questionId, _):
            return "/questions/\(questionId)"
        }
    }
    
    public var method: Moya.Method {
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
