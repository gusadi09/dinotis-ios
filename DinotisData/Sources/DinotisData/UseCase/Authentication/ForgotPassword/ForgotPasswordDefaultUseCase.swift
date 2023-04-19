//
//  File.swift
//  
//
//  Created by Gus Adi on 06/03/23.
//

import Foundation

public struct ForgotPasswordDefaultUseCase: ForgotPasswordUseCase {
    private let repository: AuthenticationRepository
    private let state = StateObservable.shared

    public init(repository: AuthenticationRepository = AuthenticationDefaultRepository()) {
        self.repository = repository
    }

    public func execute(with params: OTPRequest) async -> Result<SuccessResponse, Error> {
        do {
            let data = try await self.repository.forgetPassword(by: params)
            
            return .success(data)
        } catch (let error as ErrorResponse) {
            return .failure(error)
        } catch (let e) {
            return .failure(e)
        }
    }
}
