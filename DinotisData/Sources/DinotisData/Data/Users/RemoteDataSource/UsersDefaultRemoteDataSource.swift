//
//  UsersDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import Combine
import Moya

public final class UsersDefaultRemoteDataSource: UsersRemoteDataSource {

	private let provider: MoyaProvider<UsersTargetType>

	public init(provider: MoyaProvider<UsersTargetType> = .defaultProvider()) {
		self.provider = provider
	}

    public func getUsers() async throws -> UserResponse {
		try await provider.request(.getUsers, model: UserResponse.self)
	}

    public func updateUser(with data: EditUserRequest) async throws -> UserResponse {
        try await provider.request(.updateUser(data), model: UserResponse.self)
	}

    public func usernameSuggest(with suggest: UsernameSuggestionRequest) async throws -> UsernameAvailabilityResponse {
        try await provider.request(.usernameSuggest(suggest), model: UsernameAvailabilityResponse.self)
	}

    public func usernameAvailability(with username: UsernameAvailabilityRequest) async throws -> SuccessResponse {
        try await provider.request(.usernameAvailability(username), model: SuccessResponse.self)
	}

    public func userCurrentBalance() async throws -> CurrentBalanceResponse {
        try await provider.request(.userCurrentBalance, model: CurrentBalanceResponse.self)
	}

    public func updateImage(with photo: EditUserPhotoRequest) async throws -> SuccessResponse {
        try await provider.request(.updateImage(photo), model: SuccessResponse.self)
	}

    public func deleteUserAccount() async throws -> SuccessResponse {
        try await provider.request(.deleteUser, model: SuccessResponse.self)
	}
}
