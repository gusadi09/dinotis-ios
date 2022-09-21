//
//  UsersRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import Combine

protocol UsersRemoteDataSource {
	func getUsers() -> AnyPublisher<Users, UnauthResponse>
	func updateUser(with data: UpdateUser) -> AnyPublisher<Users, UnauthResponse>
	func usernameSuggest(with suggest: SuggestionBody) -> AnyPublisher<UsernameBody, UnauthResponse>
	func usernameAvailability(with username: UsernameBody) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func usernameAvailabilityOnEdit(with username: UsernameBody) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func userCurrentBalance() -> AnyPublisher<CurrentBalance, UnauthResponse>
	func updateImage(with photo: PhotoProfileUrl) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func deleteUserAccount() -> AnyPublisher<SuccessResponse, UnauthResponse>
}
