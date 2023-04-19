//
//  FriendshipRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/12/22.
//

import Foundation

public protocol FriendshipRemoteDataSource {
	func getFollowedCreator(query: GeneralParameterRequest) async throws -> FriendshipResponse
	func followCreator(for talentId: String) async throws -> SuccessResponse
	func unfollowCreator(for talentId: String) async throws -> SuccessResponse
}
