//
//  TalentRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/02/22.
//

import Foundation
import Combine

protocol TalentRemoteDataSource {
	func getCrowdedTalent(query: TalentQueryParams) -> AnyPublisher<SearchResponse, UnauthResponse>
	func getRecommendationTalent(query: TalentQueryParams) -> AnyPublisher<SearchResponse, UnauthResponse>
	func getSearchedTalent(query: TalentQueryParams) -> AnyPublisher<SearchResponse, UnauthResponse>
	func getDetailTalent(username: String) -> AnyPublisher<TalentFromSearch, UnauthResponse>
	func sendRequestSchedule(talentId: String, body: RequestScheduleBody) -> AnyPublisher<RequestScheduleResponse, UnauthResponse>
}
