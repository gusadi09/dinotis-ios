//
//  RateCardDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 10/11/22.
//

import Foundation
import Combine

public final class RateCardDefaultRepository: RateCardRepository {

	private let remote: RateCardRemoteDataSource

	public init(remote: RateCardRemoteDataSource = RateCardDefaulRemoteDataSource()) {
		self.remote = remote
	}

	public func provideEditRateCard(by id: String, contain body: CreateRateCardRequest) async throws -> RateCardResponse {
		try await remote.editRateCard(by: id, contain: body)
	}

	public func provideUserGetRateCardList(by creatorId: String, query: RateCardFilterRequest) async throws -> RateCardListResponse {
		try await remote.userGetRateCardList(by: creatorId, query: query)
	}

	public func provideGetTalentMeetingRequests(by filter: RateCardFilterRequest) async throws -> MeetingRequestsResponse {
		try await remote.getTalentMeetingRequests(by: filter)
	}

	public func provideRequestSession(with body: RequestSessionRequest) async throws -> UserBookingData {
		try await remote.requestSession(with: body)
	}

	public func providePaySession(with body: RequestSessionRequest) async throws -> UserBookingData {
		try await remote.paySession(with: body)
	}

	public func provideGetConversationToken(with id: String) async throws -> CustomerChatTokenResponse {
		try await remote.getConversationToken(with: id)
	}

	public func provideConfirmRequest(with id: String, contain body: ConfirmationRateCardRequest) async throws -> SuccessResponse {
		try await remote.confirmRequest(with: id, contain: body)
	}

	public func provideEditRequestedSession(by id: String, with body: EditRequestedSessionRequest) async throws -> UserMeetingData {
		try await remote.editRequestedSession(by: id, with: body)
	}

	public func provideCreateRateCard(with body: CreateRateCardRequest) async throws -> RateCardResponse {
		try await remote.createRateCard(with: body)
	}

	public func provideGetRateCardList(by query: GeneralParameterRequest) async throws -> RateCardListResponse {
		try await remote.getRateCardList(by: query)
	}

	public func provideDeleteRateCard(with id: String) async throws -> SuccessResponse {
		try await remote.deleteRateCard(with: id)
	}

	public func provideGetDetailRateCard(by id: String) async throws -> RateCardResponse {
		try await remote.getDetailRateCard(by: id)
	}
}
