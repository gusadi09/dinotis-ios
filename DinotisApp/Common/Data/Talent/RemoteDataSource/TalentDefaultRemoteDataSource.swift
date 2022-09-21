//
//  TalentDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/02/22.
//

import Foundation
import Moya
import Combine

final class TalentDefaultRemoteDataSource: TalentRemoteDataSource {

	private let provider: MoyaProvider<TalentTargetType>
	
	init(provider: MoyaProvider<TalentTargetType> = .defaultProvider()) {
		self.provider = provider
	}
	
	func getCrowdedTalent(query: TalentQueryParams) -> AnyPublisher<SearchResponse, UnauthResponse> {
		provider.request(.getCrowdedTalent(query), model: SearchResponse.self)
	}
	
	func getRecommendationTalent(query: TalentQueryParams) -> AnyPublisher<SearchResponse, UnauthResponse> {
		provider.request(.getRecommendationTalent(query), model: SearchResponse.self)
	}
	
	func getSearchedTalent(query: TalentQueryParams) -> AnyPublisher<SearchResponse, UnauthResponse> {
		provider.request(.getSearchedTalent(query), model: SearchResponse.self)
	}
	
	func getDetailTalent(username: String) -> AnyPublisher<TalentFromSearch, UnauthResponse> {
		provider.request(.getTalentDetail(username), model: TalentFromSearch.self)
	}

	func sendRequestSchedule(talentId: String, body: RequestScheduleBody) -> AnyPublisher<RequestScheduleResponse, UnauthResponse> {
		provider.request(.sendRequestSchedule(talentId, body), model: RequestScheduleResponse.self)
	}
}
