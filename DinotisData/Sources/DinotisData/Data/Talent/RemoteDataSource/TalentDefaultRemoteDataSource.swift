//
//  TalentDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/02/22.
//

import Foundation
import Moya
import Combine

public final class TalentDefaultRemoteDataSource: TalentRemoteDataSource {

	private let provider: MoyaProvider<TalentTargetType>
	
    public init(provider: MoyaProvider<TalentTargetType> = .defaultProvider()) {
		self.provider = provider
	}
	
    public func getCrowdedTalent(query: TalentsRequest) async throws -> SearchTalentResponse {
		try await provider.request(.getCrowdedTalent(query), model: SearchTalentResponse.self)
	}
	
    public func getRecommendationTalent(query: TalentsRequest) async throws -> SearchTalentResponse {
        try await provider.request(.getRecommendationTalent(query), model: SearchTalentResponse.self)
	}
	
    public func getSearchedTalent(query: TalentsRequest) async throws -> SearchTalentResponse {
        try await provider.request(.getSearchedTalent(query), model: SearchTalentResponse.self)
	}
	
    public func getDetailTalent(username: String) async throws -> TalentFromSearchResponse {
        try await provider.request(.getTalentDetail(username), model: TalentFromSearchResponse.self)
	}

    public func sendRequestSchedule(talentId: String, body: SendScheduleRequest) async throws -> RequestScheduleResponse {
        try await provider.request(.sendRequestSchedule(talentId, body), model: RequestScheduleResponse.self)
	}
}
