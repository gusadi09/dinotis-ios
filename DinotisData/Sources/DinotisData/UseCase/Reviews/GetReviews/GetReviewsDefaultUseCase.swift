//
//  File.swift
//  
//
//  Created by Gus Adi on 04/02/23.
//

import Foundation

public struct GetReviewsDefaultUseCase: GetReviewsUseCase {

	private let repository: ReviewsRepository
	private let authRepository: AuthenticationRepository
	private let state = StateObservable.shared

	public init(
		repository: ReviewsRepository = ReviewsDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
	) {
		self.repository = repository
		self.authRepository = authRepository
	}

	public func execute(by talentId: String, for params: GeneralParameterRequest) async -> Result<ReviewsResponse, Error> {
		do {
			let data = try await repository.provideGetReviews(by: talentId, for: params)

			return .success(data)
		} catch (let error as ErrorResponse) {
			if error.statusCode.orZero() == 401 {
				let result = await refreshToken()

				switch result {
				case .success(let token):
					state.accessToken = token.accessToken.orEmpty()
					state.refreshToken = token.refreshToken.orEmpty()

					let data = await execute(by: talentId, for: params)
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
