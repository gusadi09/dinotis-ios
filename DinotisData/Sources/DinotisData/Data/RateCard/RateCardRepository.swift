//
//  RateCardRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 10/11/22.
//

import Foundation
import Combine

public protocol RateCardRepository {
	func provideCreateRateCard(with body: CreateRateCardRequest) async throws -> RateCardResponse
	func provideGetRateCardList(by query: GeneralParameterRequest) async throws -> RateCardListResponse
	func provideDeleteRateCard(with id: String) async throws -> SuccessResponse
	func provideGetDetailRateCard(by id: String) async throws -> RateCardResponse
	func provideEditRateCard(by id: String, contain body: CreateRateCardRequest) async throws -> RateCardResponse
	func provideUserGetRateCardList(by creatorId: String, query: RateCardFilterRequest) async throws -> RateCardListResponse
	func provideGetTalentMeetingRequests(by filter: RateCardFilterRequest) async throws -> MeetingRequestsResponse
	func provideRequestSession(with body: RequestSessionRequest) async throws -> UserBookingData
	func providePaySession(with body: RequestSessionRequest) async throws -> UserBookingData
	func provideGetConversationToken(with id: String) async throws -> CustomerChatTokenResponse
	func provideConfirmRequest(with id: String, contain body: ConfirmationRateCardRequest) async throws -> SuccessResponse
	func provideEditRequestedSession(by id: String, with body: EditRequestedSessionRequest) async throws -> UserMeetingData
}
