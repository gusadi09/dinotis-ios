//
//  UsersRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import Combine

public protocol UsersRepository {
	func provideGetUsers() async throws -> UserResponse
	func provideUpdateUser(with data: EditUserRequest) async throws -> UserResponse
	func provideUsernameSuggest(with suggest: UsernameSuggestionRequest) async throws -> UsernameAvailabilityResponse
	func provideUsernameAvailability(with username: UsernameAvailabilityRequest) async throws -> SuccessResponse
	func provideUserCurrentBalance() async throws -> CurrentBalanceResponse
	func provideUpdateImage(with photo: EditUserPhotoRequest) async throws -> SuccessResponse
	func provideDeleteUserAccount() async throws -> SuccessResponse
    func provideCreatorAvailability(body: CreatorAvailabilityRequest) async throws -> SuccessResponse
    func provideSendVerifRequest(links: [String]) async throws -> VerificationReqResponse
}
