//
//  UsersDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import Combine
import Moya

final class UsersDefaultRemoteDataSource: UsersRemoteDataSource {

	private let provider: MoyaProvider<UsersTargetType>

	init(provider: MoyaProvider<UsersTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	func getUsers() -> AnyPublisher<Users, UnauthResponse> {
		provider.request(.getUsers, model: Users.self)
	}

	func updateUser(with data: UpdateUser) -> AnyPublisher<Users, UnauthResponse> {
		provider.request(.updateUser(data), model: Users.self)
	}

	func usernameSuggest(with suggest: SuggestionBody) -> AnyPublisher<UsernameBody, UnauthResponse> {
		provider.request(.usernameSuggest(suggest), model: UsernameBody.self)
	}

	func usernameAvailability(with username: UsernameBody) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		provider.request(.usernameAvailability(username), model: SuccessResponse.self)
	}

	func usernameAvailabilityOnEdit(with username: UsernameBody) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		provider.request(.usernameAvailabilityOnEdit(username), model: SuccessResponse.self)
	}

	func userCurrentBalance() -> AnyPublisher<CurrentBalance, UnauthResponse> {
		provider.request(.userCurrentBalance, model: CurrentBalance.self)
	}

	func updateImage(with photo: PhotoProfileUrl) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		provider.request(.updateImage(photo), model: SuccessResponse.self)
	}

	func deleteUserAccount() -> AnyPublisher<SuccessResponse, UnauthResponse> {
		provider.request(.deleteUser, model: SuccessResponse.self)
	}
}
