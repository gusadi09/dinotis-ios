//
//  TalentDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/02/22.
//

import Foundation
import Combine

final class TalentDefaultRepository: TalentRepository {

	private let remoteDataSource: TalentRemoteDataSource
	
	init(remoteDataSource: TalentRemoteDataSource = TalentDefaultRemoteDataSource()) {
		self.remoteDataSource = remoteDataSource
	}
	
	func provideGetCrowdedTalent(with query: TalentQueryParams) -> AnyPublisher<SearchResponse, UnauthResponse> {
		self.remoteDataSource.getCrowdedTalent(query: query)
	}
	
	func provideGetRecommendationTalent(with query: TalentQueryParams) -> AnyPublisher<SearchResponse, UnauthResponse> {
		self.remoteDataSource.getRecommendationTalent(query: query)
	}
	
	func provideGetSearchedTalent(with query: TalentQueryParams) -> AnyPublisher<SearchResponse, UnauthResponse> {
		self.remoteDataSource.getSearchedTalent(query: query)
	}
	
	func provideGetDetailTalent(by username: String) -> AnyPublisher<TalentFromSearch, UnauthResponse> {
		self.remoteDataSource.getDetailTalent(username: username)
	}

	func provideSendRequestSchedule(talentId: String, body: RequestScheduleBody) -> AnyPublisher<RequestScheduleResponse, UnauthResponse> {
		self.remoteDataSource.sendRequestSchedule(talentId: talentId, body: body)
	}
}
