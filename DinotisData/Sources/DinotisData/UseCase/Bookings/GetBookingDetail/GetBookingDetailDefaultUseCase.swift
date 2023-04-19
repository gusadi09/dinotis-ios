//
//  File.swift
//  
//
//  Created by Gus Adi on 14/02/23.
//

import Foundation

public struct GetBookingDetailDefaultUseCase: GetBookingDetailUseCase {

	private let authRepository: AuthenticationRepository
	private let bookingsRepository: BookingsRepository
	private let state = StateObservable.shared

	public init(
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		bookingsRepository: BookingsRepository = BookingsDefaultRepository()
	) {
		self.authRepository = authRepository
		self.bookingsRepository = bookingsRepository
	}

	public func execute(by bookingId: String) async -> Result<UserBookingData, Error> {
		do {
			let data = try await bookingsRepository.provideGetBookingsById(bookingId: bookingId)

			return .success(data)
		} catch (let error as ErrorResponse) {
			if error.statusCode.orZero() == 401 {
				let result = await refreshToken()

				switch result {
				case .failure(let error):
					if let e = error as? ErrorResponse {
						return .failure(e)
					} else {
						return .failure(error)
					}

				case .success(let token):
                    await state.setToken(token: token)

					let data = await execute(by: bookingId)

					return data
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
