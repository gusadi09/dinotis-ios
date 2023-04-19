//
//  FriendshipDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/12/22.
//

import Foundation
import Combine
import Moya

public final class FriendshipDefaultRemoteDataSource: FriendshipRemoteDataSource {

	private let provider: MoyaProvider<FriendshipTargetType>

	public init(provider: MoyaProvider<FriendshipTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	public func getFollowedCreator(query: GeneralParameterRequest) async throws -> FriendshipResponse {
		try await self.provider.request(.getFollowedCreator(query), model: FriendshipResponse.self)
	}

	public func followCreator(for talentId: String) async throws -> SuccessResponse {
		try await self.provider.request(.followCreator(talentId), model: SuccessResponse.self)
	}

	public func unfollowCreator(for talentId: String) async throws -> SuccessResponse {
		try await self.provider.request(.unfollowCreator(talentId), model: SuccessResponse.self)
	}
}
