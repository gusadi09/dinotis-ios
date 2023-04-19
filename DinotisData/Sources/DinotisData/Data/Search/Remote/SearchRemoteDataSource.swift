//
//  File.swift
//  
//
//  Created by Garry on 27/01/23.
//

import Foundation

public protocol SearchRemoteDataSource {
    func getRecommendation(query: SearchQueryParam) async throws -> RecommendationResponse
    func getSearchData(query: SearchQueryParam) async throws -> SearchResponse
    func getSearchCreator(query: SearchQueryParam) async throws -> SearchedResponse
}
