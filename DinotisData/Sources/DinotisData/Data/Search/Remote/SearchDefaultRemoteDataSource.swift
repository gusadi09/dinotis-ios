//
//  File.swift
//  
//
//  Created by Garry on 27/01/23.
//

import Foundation
import Moya

public final class SearchDefaultRemoteDataSource: SearchRemoteDataSource {
    
    private let provider: MoyaProvider<SearchTargetType>
    
    public init(provider: MoyaProvider<SearchTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    public func getRecommendation(query: SearchQueryParam) async throws -> RecommendationResponse {
        try await provider.request(.getRecommendation(query), model: RecommendationResponse.self)
    }
    
    public func getSearchData(query: SearchQueryParam) async throws -> SearchResponse {
        try await provider.request(.getSearchedData(query), model: SearchResponse.self)
    }
    
    public func getSearchCreator(query: SearchQueryParam) async throws -> SearchedResponse {
        try await provider.request(.getSearchedCreator(query), model: SearchedResponse.self)
    }
}
