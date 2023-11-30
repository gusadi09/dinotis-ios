//
//  GetSubscriptionsDefaultUseCase.swift
//
//
//  Created by Irham Naufal on 30/11/23.
//

import Foundation

public struct GetSubscriptionsDefaultUseCase: GetSubscriptionsUseCase {
    
    private let repository: SubscriptionRepository
    private let authRepository: AuthenticationRepository
    private let state = StateObservable.shared

    public init(
        repository: SubscriptionRepository = SubscriptionDefaultRepository(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
    ) {
        self.repository = repository
        self.authRepository = authRepository
    }
    
    public func execute(param: GeneralParameterRequest) async -> Result<SubscriptionListResponse, Error> {
        do {
            let data = try await repository.provideGetSubscriptions(param: param)
            
            return .success(data)
        } catch(let error as ErrorResponse) {
            if error.statusCode.orZero() == 401 {
                let result = await refreshToken()

                switch result {
                case .success(let token):
                    state.accessToken = token.accessToken.orEmpty()
                    state.refreshToken = token.refreshToken.orEmpty()

                    let data = await execute(param: param)
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
        } catch(let error) {
            return .failure(error)
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
