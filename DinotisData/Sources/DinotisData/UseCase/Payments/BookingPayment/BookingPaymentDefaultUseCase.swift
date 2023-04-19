//
//  File.swift
//  
//
//  Created by Gus Adi on 17/02/23.
//

import Foundation

public struct BookingPaymentDefaultUseCase: BookingPaymentUseCase {
	private let paymentRepository: PaymentsRepository
	private let authRepository: AuthenticationRepository
	private let state = StateObservable.shared

	public init(
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		paymentRepository: PaymentsRepository = PaymentsDefaultRepository()
	) {
		self.authRepository = authRepository
		self.paymentRepository = paymentRepository
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

	public func execute(with request: BookingPaymentRequest) async -> Result<UserBookingData, Error> {
		do {
			let data = try await paymentRepository.provideBookingPayment(body: request)

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
					state.accessToken = token.accessToken.orEmpty()
					state.refreshToken = token.refreshToken.orEmpty()

					let data = await execute(with: request)

					return data
				}
			} else {
				return .failure(error)
			}
		} catch (let e) {
			return .failure(e)
		}
	}
}
