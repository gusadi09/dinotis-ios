//
//  File.swift
//  
//
//  Created by Gus Adi on 26/11/23.
//

import Foundation
import Moya

public enum SubscriptionTargetType {
    case subscribe(String, Int)
    case unsubscribe(String)
}

extension SubscriptionTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .subscribe(let userId, let paymentMethodId):
            return [
                "userId": userId,
                "paymentMethodId": paymentMethodId
            ]
            
        case .unsubscribe(let userId):
            return ["userId" : userId]
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        default:
            return [:]
        }
        
    }
    
    public var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        default:
            return JSONEncoding.default
        }
    }
    
    public var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }
    
    public var path: String {
        switch self {
        case .subscribe:
            return "/subscription/subscribe"
        case .unsubscribe:
            return "/subscription/unsubscribe"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
}
