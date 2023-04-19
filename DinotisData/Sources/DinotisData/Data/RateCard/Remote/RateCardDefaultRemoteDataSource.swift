//
//  RateCardDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 10/11/22.
//

import Foundation
import Moya
import Combine

public final class RateCardDefaulRemoteDataSource: RateCardRemoteDataSource {

	private let provider: MoyaProvider<RateCardTargetType>

	public init(provider: MoyaProvider<RateCardTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	public func createRateCard(with body: CreateRateCardRequest) async throws -> RateCardResponse {
		try await self.provider.request(.createRateCard(body), model: RateCardResponse.self)
	}

	public func getRateCardList(by query: GeneralParameterRequest) async throws -> RateCardListResponse {
		try await self.provider.request(.getRateCardList(query), model: RateCardListResponse.self)
	}

	public func deleteRateCard(with id: String) async throws -> SuccessResponse {
		try await self.provider.request(.deleteRateCard(id), model: SuccessResponse.self)
	}

	public func getDetailRateCard(by id: String) async throws -> RateCardResponse {
		try await self.provider.request(.getDetailRateCard(id), model: RateCardResponse.self)
	}

	public func editRateCard(by id: String, contain body: CreateRateCardRequest) async throws -> RateCardResponse {
		try await self.provider.request(.editRateCard(id, body), model: RateCardResponse.self)
	}

	public func userGetRateCardList(by creatorId: String, query: RateCardFilterRequest) async throws -> RateCardListResponse {
		try await self.provider.request(.userGetRateCard(creatorId, query), model: RateCardListResponse.self)
	}

	public func getTalentMeetingRequests(by filter: RateCardFilterRequest) async throws -> MeetingRequestsResponse {
		try await self.provider.request(.getMeetingRequests(filter), model: MeetingRequestsResponse.self)
	}

	public func requestSession(with body: RequestSessionRequest) async throws -> UserBookingData {
		try await self.provider.request(.requestSession(body), model: UserBookingData.self)
	}

	public func paySession(with body: RequestSessionRequest) async throws -> UserBookingData {
		try await self.provider.request(.paySession(body), model: UserBookingData.self)
	}

	public func getConversationToken(with id: String) async throws -> CustomerChatTokenResponse {
		try await self.provider.request(.getConversationToken(id), model: CustomerChatTokenResponse.self)
	}

	public func confirmRequest(with id: String, contain body: ConfirmationRateCardRequest) async throws -> SuccessResponse {
		try await self.provider.request(.confirmRequest(id, body), model: SuccessResponse.self)
	}

	public func editRequestedSession(by id: String, with body: EditRequestedSessionRequest) async throws -> UserMeetingData {
		try await self.provider.request(.editRequestedSession(id, body), model: UserMeetingData.self)
	}
}
