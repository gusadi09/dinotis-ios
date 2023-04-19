//
//  File.swift
//  
//
//  Created by Gus Adi on 07/03/23.
//

import Foundation

public struct ResendOTPDefaultUseCase: ResendOTPUseCase {
    private let repository: AuthenticationRepository
    private let state = StateObservable.shared

    public init(repository: AuthenticationRepository = AuthenticationDefaultRepository()) {
        self.repository = repository
    }

    public func execute(with params: OTPRequest) async -> Result<SuccessResponse, Error> {
        do {
            let data = try await self.repository.resendOTP(with: params)

            return .success(data)
        } catch (let error as ErrorResponse) {
            return .failure(error)
        } catch (let e) {
            return .failure(e)
        }
    }
}
