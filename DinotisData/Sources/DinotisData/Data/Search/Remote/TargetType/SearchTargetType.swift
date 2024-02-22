//
//  File.swift
//  
//
//  Created by Garry on 27/01/23.
//

import Foundation
import Moya

public enum SearchTargetType {
    case getRecommendation(SearchQueryParam)
    case getSearchedData(SearchQueryParam)
    case getSearchedCreator(SearchQueryParam)
}

extension SearchTargetType: DinotisTargetType, AccessTokenAuthorizable {
    public var headers: [String: String]? {
        return [:]
    }
    
    public var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .getRecommendation:
            return URLEncoding.queryString
        case .getSearchedData:
            return URLEncoding.queryString
        case .getSearchedCreator:
            return URLEncoding.queryString
        }
    }

    public var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }

    var parameters: [String : Any] {
        switch self {
        case .getRecommendation(let query):
            return query.toJSON()
        case .getSearchedData(let query):
            return query.toJSON()
        case .getSearchedCreator(let query):
            return query.toJSON()
        }
    }

    public var path: String {
        switch self {
        case .getRecommendation:
            return "/talents/recommendation"
        case .getSearchedData:
            return "/home/feature/all"
        case .getSearchedCreator:
            return "/talents"
        }
    }

    public var sampleData: Data {
        switch self {
        case .getRecommendation(_):
            return Data()
        case .getSearchedData(_):
            return Data()
        case .getSearchedCreator(_):
            return Data()
        }
    }

    public var method:Moya.Method {
        switch self {
        case .getRecommendation:
            return .get
        case .getSearchedData:
            return .get
        case .getSearchedCreator:
            return .get
        }
    }
}
