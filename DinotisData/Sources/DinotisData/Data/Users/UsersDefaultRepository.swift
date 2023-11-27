//
//  UsersDefaultRemoteRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import Combine

public final class UsersDefaultRepository: UsersRepository {

	private let remoteDataSource: UsersRemoteDataSource

	public init(remoteDataSource: UsersRemoteDataSource = UsersDefaultRemoteDataSource()) {
		self.remoteDataSource = remoteDataSource
	}

    public func provideGetUsers() async throws -> UserResponse {
		try await remoteDataSource.getUsers()
	}

    public func provideUpdateUser(with data: EditUserRequest) async throws -> UserResponse {
		try await remoteDataSource.updateUser(with: data)
	}

    public func provideUsernameSuggest(with suggest: UsernameSuggestionRequest) async throws -> UsernameAvailabilityResponse {
		try await remoteDataSource.usernameSuggest(with: suggest)
	}

	public func provideUsernameAvailability(with username: UsernameAvailabilityRequest) async throws -> SuccessResponse {
		try await remoteDataSource.usernameAvailability(with: username)
	}

	public func provideUserCurrentBalance() async throws -> CurrentBalanceResponse {
		try await remoteDataSource.userCurrentBalance()
	}

	public func provideUpdateImage(with photo: EditUserPhotoRequest) async throws -> SuccessResponse {
		try await remoteDataSource.updateImage(with: photo)
	}

	public func provideDeleteUserAccount() async throws -> SuccessResponse {
		try await remoteDataSource.deleteUserAccount()
	}
    
    public func provideCreatorAvailability(body: CreatorAvailabilityRequest) async throws -> SuccessResponse {
        try await self.remoteDataSource.creatorAvailability(body: body)
    }
}
