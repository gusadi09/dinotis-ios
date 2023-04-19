//
//  FriendshipRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/12/22.
//

import Foundation
import Combine

public protocol FriendshipRepository {
	func provideGetFollowedCreator(with query: GeneralParameterRequest) async throws -> FriendshipResponse
	func provideFollowCreator(for talentId: String) async throws -> SuccessResponse
	func provideUnfollowCreator(for talentId: String) async throws -> SuccessResponse
}
