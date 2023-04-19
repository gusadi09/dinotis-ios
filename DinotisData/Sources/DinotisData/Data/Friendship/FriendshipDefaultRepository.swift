//
//  FriendshipDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/12/22.
//

import Foundation
import Combine

public final class FriendshipDefaultRepository: FriendshipRepository {

	private let remote: FriendshipRemoteDataSource

	public init(remote: FriendshipRemoteDataSource = FriendshipDefaultRemoteDataSource()) {
		self.remote = remote
	}

	public func provideGetFollowedCreator(with query: GeneralParameterRequest) async throws -> FriendshipResponse {
		try await self.remote.getFollowedCreator(query: query)
	}

	public func provideFollowCreator(for talentId: String) async throws -> SuccessResponse {
		try await self.remote.followCreator(for: talentId)
	}

	public func provideUnfollowCreator(for talentId: String) async throws -> SuccessResponse {
		try await self.remote.unfollowCreator(for: talentId)
	}
}
