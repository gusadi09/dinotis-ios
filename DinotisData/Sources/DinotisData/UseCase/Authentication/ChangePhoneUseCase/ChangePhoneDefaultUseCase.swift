//
//  File.swift
//  
//
//  Created by Gus Adi on 07/03/23.
//

import Foundation

public struct ChangePhoneDefaultUseCase: ChangePhoneUseCase {
    
    private let repository: AuthenticationRepository
    private let state = StateObservable.shared

    public init(
        repository: AuthenticationRepository = AuthenticationDefaultRepository()
    ) {
        self.repository = repository
    }

    public func execute(with params: OTPRequest) async -> Result<SuccessResponse, Error> {
        do {
            let data = try await repository.changePhone(with: params)

            return .success(data)
        } catch (let error as ErrorResponse) {
            if error.statusCode.orZero() == 401 {
                let result = await refreshToken()

                switch result {
                case .success(let token):
                    await state.setToken(token: token)

                    let data = await execute(with: params)
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
            let data = try await repository.refreshToken()

            return .success(data)
        } catch (let error as ErrorResponse) {
            return .failure(error)
        } catch (let e) {
            return .failure(e)
        }
    }
}
