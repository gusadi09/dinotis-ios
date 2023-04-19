//
//  File.swift
//  
//
//  Created by Garry on 27/01/23.
//

import Foundation

public protocol SearchRepository {
    func provideGetRecommendation(query: SearchQueryParam) async throws -> RecommendationResponse
    func provideGetSearchData(query: SearchQueryParam) async throws -> SearchResponse
    func provideGetSearchCreator(query: SearchQueryParam) async throws -> SearchedResponse
}
