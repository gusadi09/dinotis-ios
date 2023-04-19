//
//  File.swift
//  
//
//  Created by Gus Adi on 09/03/23.
//

import Foundation

public struct UsernameSuggestionDefaultUseCase: UsernameSuggestionUseCase {
    
    private let repository: UsersRepository
    private let authRepository: AuthenticationRepository
    private let state = StateObservable.shared
    
    public init(
        repository: UsersRepository = UsersDefaultRepository(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
    ) {
        self.repository = repository
        self.authRepository = authRepository
    }
    
    public func execute(with suggest: UsernameSuggestionRequest) async -> Result<UsernameAvailabilityResponse, Error> {
        do {
            let data = try await repository.provideUsernameSuggest(with: suggest)
            
            return .success(data)
        } catch (let error as ErrorResponse) {
            if error.statusCode.orZero() == 401 {
                let result = await refreshToken()
                
                switch result {
                case .success(let token):
                    state.accessToken = token.accessToken.orEmpty()
                    state.refreshToken = token.refreshToken.orEmpty()
                    
                    let data = await execute(with: suggest)
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
