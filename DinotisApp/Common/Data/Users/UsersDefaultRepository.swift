//
//  UsersDefaultRemoteRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import Combine

final class UsersDefaultRepository: UsersRepository {

	private let remoteDataSource: UsersRemoteDataSource

	init(remoteDataSource: UsersRemoteDataSource = UsersDefaultRemoteDataSource()) {
		self.remoteDataSource = remoteDataSource
	}

	func provideGetUsers() -> AnyPublisher<Users, UnauthResponse> {
		remoteDataSource.getUsers()
	}

	func provideUpdateUser(with data: UpdateUser) -> AnyPublisher<Users, UnauthResponse> {
		remoteDataSource.updateUser(with: data)
	}

	func provideUsernameSuggest(with suggest: SuggestionBody) -> AnyPublisher<UsernameBody, UnauthResponse> {
		remoteDataSource.usernameSuggest(with: suggest)
	}

	func provideUsernameAvailability(with username: UsernameBody) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		remoteDataSource.usernameAvailability(with: username)
	}

	func provideUsernameAvailabilityOnEdit(with username: UsernameBody) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		remoteDataSource.usernameAvailabilityOnEdit(with: username)
	}

	func provideUserCurrentBalance() -> AnyPublisher<CurrentBalance, UnauthResponse> {
		remoteDataSource.userCurrentBalance()
	}

	func provideUpdateImage(with photo: PhotoProfileUrl) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		remoteDataSource.updateImage(with: photo)
	}

	func provideDeleteUserAccount() -> AnyPublisher<SuccessResponse, UnauthResponse> {
		remoteDataSource.deleteUserAccount()
	}
}
