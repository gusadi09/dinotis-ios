//
//  TalentRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 28/02/22.
//

import Foundation
import Combine

public protocol TalentRepository {
    func provideGetCrowdedTalent(with query: TalentsRequest) async throws -> SearchTalentResponse
    func provideGetRecommendationTalent(with query: TalentsRequest) async throws -> SearchTalentResponse
    func provideGetSearchedTalent(with query: TalentsRequest) async throws -> SearchTalentResponse
    func provideGetDetailTalent(by username: String) async throws -> TalentFromSearchResponse
    func provideSendRequestSchedule(talentId: String, body: SendScheduleRequest) async throws -> RequestScheduleResponse
}
