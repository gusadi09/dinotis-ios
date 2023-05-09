//
//  TalentDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/02/22.
//

import Foundation
import Combine

public final class TalentDefaultRepository: TalentRepository {

	private let remoteDataSource: TalentRemoteDataSource
	
	public init(remoteDataSource: TalentRemoteDataSource = TalentDefaultRemoteDataSource()) {
		self.remoteDataSource = remoteDataSource
	}
	
    public func provideGetCrowdedTalent(with query: TalentsRequest) async throws -> SearchTalentResponse {
		try await self.remoteDataSource.getCrowdedTalent(query: query)
	}
	
    public func provideGetRecommendationTalent(with query: TalentsRequest) async throws -> SearchTalentResponse {
        try await self.remoteDataSource.getRecommendationTalent(query: query)
	}
	
    public func provideGetSearchedTalent(with query: TalentsRequest) async throws -> SearchTalentResponse {
        try await self.remoteDataSource.getSearchedTalent(query: query)
	}
	
    public func provideGetDetailTalent(by username: String) async throws -> TalentFromSearchResponse {
        try await self.remoteDataSource.getDetailTalent(username: username)
	}

    public func provideSendRequestSchedule(talentId: String, body: SendScheduleRequest) async throws -> RequestScheduleResponse {
        try await self.remoteDataSource.sendRequestSchedule(talentId: talentId, body: body)
	}
}
