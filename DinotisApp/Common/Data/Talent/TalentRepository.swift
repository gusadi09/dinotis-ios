//
//  TalentRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/02/22.
//

import Foundation
import Combine

protocol TalentRepository {
	func provideGetCrowdedTalent(with query: TalentQueryParams) -> AnyPublisher<SearchResponse, UnauthResponse>
	func provideGetRecommendationTalent(with query: TalentQueryParams) -> AnyPublisher<SearchResponse, UnauthResponse>
	func provideGetSearchedTalent(with query: TalentQueryParams) -> AnyPublisher<SearchResponse, UnauthResponse>
	func provideGetDetailTalent(by username: String) -> AnyPublisher<TalentFromSearch, UnauthResponse>
	func provideSendRequestSchedule(talentId: String, body: RequestScheduleBody) -> AnyPublisher<RequestScheduleResponse, UnauthResponse>
}
