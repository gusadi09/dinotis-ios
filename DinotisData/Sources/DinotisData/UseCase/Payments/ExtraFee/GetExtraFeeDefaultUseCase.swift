//
//  File.swift
//  
//
//  Created by Garry on 02/02/23.
//

import Foundation

public struct GetExtraFeeDefaultUseCase: GetExtraFeeUseCase {

    private let authRepository: AuthenticationRepository
    private let paymentRepository: PaymentsRepository
    private let state = StateObservable.shared

    public init(
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        paymentRepository: PaymentsRepository = PaymentsDefaultRepository()
    ) {
        self.authRepository = authRepository
        self.paymentRepository = paymentRepository
    }

    public func execute(by body: PaymentExtraFeeRequest) async -> Result<Int, Error> {
        do {
            let data = try await paymentRepository.provideExtraFee(body: body)

            return .success(data.extraFee.orZero())
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

                    let data = await execute(by: body)

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
