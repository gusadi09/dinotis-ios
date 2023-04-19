//
//  File.swift
//  
//
//  Created by Gus Adi on 24/02/23.
//

import Foundation

public struct UnfollowCreatorDefaultUseCase: UnfollowCreatorUseCase {

	private let repository: FriendshipRepository
	private let authRepository: AuthenticationRepository
	private let state = StateObservable.shared

	public init(
		repository: FriendshipRepository = FriendshipDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
	) {
		self.repository = repository
		self.authRepository = authRepository
	}

	public func execute(for creatorId: String) async -> Result<SuccessResponse, Error> {
		do {
			let data = try await repository.provideUnfollowCreator(for: creatorId)

			return .success(data)
		} catch (let error as ErrorResponse) {
			if error.statusCode.orZero() == 401 {
				let result = await refreshToken()

				switch result {
				case .success(let token):
                    await state.setToken(token: token)

					let data = await execute(for: creatorId)
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
