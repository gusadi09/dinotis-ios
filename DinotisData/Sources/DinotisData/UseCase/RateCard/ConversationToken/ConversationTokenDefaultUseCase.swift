//
//  File.swift
//  
//
//  Created by Gus Adi on 26/02/23.
//

import Foundation

public struct ConversationTokenDefaultUseCase: ConversationTokenUseCase {

	private let repository: RateCardRepository
	private let authRepository: AuthenticationRepository
	private let state = StateObservable.shared

	public init(
		repository: RateCardRepository = RateCardDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
	) {
		self.repository = repository
		self.authRepository = authRepository
	}

	public func execute(with id: String) async -> Result<CustomerChatTokenResponse, Error> {
		do {
			let data = try await repository.provideGetConversationToken(with: id)

			return .success(data)
		} catch (let error as ErrorResponse) {
			if error.statusCode.orZero() == 401 {
				let result = await refreshToken()

				switch result {
				case .success(let token):
					state.accessToken = token.accessToken.orEmpty()
					state.refreshToken = token.refreshToken.orEmpty()

					let data = await execute(with: id)
					return data
				case .failure(let error):
					if let err = error as? ErrorResponse {
						return .failure(err)
					} else {
						return .failure(error)
					}
				}
			} else {
				return .failure(error)
			}
		} catch (let e) {
			return .failure(e)
		}
	}

	public func refreshToken() async -> Result<LoginTokenData, Error> {
		do {
			let data = try await authRepository.refreshToken()

			return .success(data)
		} catch (let error as ErrorResponse) {
			return .failure(error)
		} catch (let e) {
			return .failure(e)
		}
	}
}
