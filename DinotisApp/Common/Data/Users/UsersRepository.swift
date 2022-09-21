//
//  UsersRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import Combine

protocol UsersRepository {
	func provideGetUsers() -> AnyPublisher<Users, UnauthResponse>
	func provideUpdateUser(with data: UpdateUser) -> AnyPublisher<Users, UnauthResponse>
	func provideUsernameSuggest(with suggest: SuggestionBody) -> AnyPublisher<UsernameBody, UnauthResponse>
	func provideUsernameAvailability(with username: UsernameBody) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func provideUsernameAvailabilityOnEdit(with username: UsernameBody) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func provideUserCurrentBalance() -> AnyPublisher<CurrentBalance, UnauthResponse>
	func provideUpdateImage(with photo: PhotoProfileUrl) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func provideDeleteUserAccount() -> AnyPublisher<SuccessResponse, UnauthResponse>
}
