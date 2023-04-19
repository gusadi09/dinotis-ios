//
//  File.swift
//  
//
//  Created by Garry on 27/01/23.
//

import Foundation

public final class SearchDefaultRepository: SearchRepository {
    
    private let remote: SearchRemoteDataSource
    
    public init(
        remote: SearchRemoteDataSource = SearchDefaultRemoteDataSource()
    ) {
        self.remote = remote
    }
    
    public func provideGetRecommendation(query: SearchQueryParam) async throws -> RecommendationResponse {
        try await remote.getRecommendation(query: query)
    }
    
    public func provideGetSearchData(query: SearchQueryParam) async throws -> SearchResponse {
        try await remote.getSearchData(query: query)
    }
    
    public func provideGetSearchCreator(query: SearchQueryParam) async throws -> SearchedResponse {
        try await remote.getSearchCreator(query: query)
    }
}
