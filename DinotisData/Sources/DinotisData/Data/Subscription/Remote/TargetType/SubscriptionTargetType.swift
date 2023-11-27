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
}

extension SubscriptionTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .subscribe(let userId, let paymentMethodId):
            return [
                "userId": userId,
                "paymentMethodId": paymentMethodId
            ]
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .subscribe:
            return [:]
        }
        
    }
    
    public var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .subscribe:
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
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .subscribe:
            return .post
        }
    }
}
