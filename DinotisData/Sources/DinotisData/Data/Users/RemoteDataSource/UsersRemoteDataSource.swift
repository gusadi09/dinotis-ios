//
//  UsersRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import Combine

public protocol UsersRemoteDataSource {
	func getUsers() async throws -> UserResponse
	func updateUser(with data: EditUserRequest) async throws -> UserResponse
	func usernameSuggest(with suggest: UsernameSuggestionRequest) async throws -> UsernameAvailabilityResponse
	func usernameAvailability(with username: UsernameAvailabilityRequest) async throws -> SuccessResponse
	func userCurrentBalance() async throws -> CurrentBalanceResponse
	func updateImage(with photo: EditUserPhotoRequest) async throws -> SuccessResponse
	func deleteUserAccount() async throws -> SuccessResponse
    func creatorAvailability(body: CreatorAvailabilityRequest) async throws -> SuccessResponse
}
