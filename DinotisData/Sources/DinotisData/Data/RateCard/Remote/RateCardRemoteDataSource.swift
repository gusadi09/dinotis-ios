//
//  RateCardRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 10/11/22.
//

import Foundation
import Combine

public protocol RateCardRemoteDataSource {
	func createRateCard(with body: CreateRateCardRequest) async throws -> RateCardResponse
	func getRateCardList(by query: GeneralParameterRequest) async throws -> RateCardListResponse
	func deleteRateCard(with id: String) async throws -> SuccessResponse
	func getDetailRateCard(by id: String) async throws -> RateCardResponse
	func editRateCard(by id: String, contain body: CreateRateCardRequest) async throws -> RateCardResponse
    func userGetRateCardList(by creatorId: String, query: RateCardFilterRequest) async throws -> RateCardListResponse
	func getTalentMeetingRequests(by filter: RateCardFilterRequest) async throws -> MeetingRequestsResponse
    func requestSession(with body: RequestSessionRequest) async throws -> UserBookingData
    func paySession(with body: RequestSessionRequest) async throws -> UserBookingData
	func getConversationToken(with id: String) async throws -> CustomerChatTokenResponse
	func confirmRequest(with id: String, contain body: ConfirmationRateCardRequest) async throws -> SuccessResponse
    func editRequestedSession(by id: String, with body: EditRequestedSessionRequest) async throws -> UserMeetingData
}
