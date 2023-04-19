//
//  File.swift
//  
//
//  Created by Gus Adi on 06/03/23.
//

import Foundation

public struct OTPForgotPasswordVerificationDefaultUseCase: OTPForgotPasswordVerificationUseCase {
    private let repository: AuthenticationRepository
    private let state = StateObservable.shared

    public init(repository: AuthenticationRepository = AuthenticationDefaultRepository()) {
        self.repository = repository
    }

    public func execute(with params: OTPVerificationRequest) async -> Result<ForgetPasswordOTPResponse, Error> {
        do {
            let data = try await self.repository.OTPForgetPasswordVerification(with: params)

            return .success(data)
        } catch (let error as ErrorResponse) {
            return .failure(error)
        } catch (let e) {
            return .failure(e)
        }
    }
}
