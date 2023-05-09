//
//  TalentRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/02/22.
//

import Foundation
import Combine

public protocol TalentRemoteDataSource {
	func getCrowdedTalent(query: TalentsRequest) async throws -> SearchTalentResponse
	func getRecommendationTalent(query: TalentsRequest) async throws -> SearchTalentResponse
	func getSearchedTalent(query: TalentsRequest) async throws -> SearchTalentResponse
	func getDetailTalent(username: String) async throws -> TalentFromSearchResponse
	func sendRequestSchedule(talentId: String, body: SendScheduleRequest) async throws -> RequestScheduleResponse
}
