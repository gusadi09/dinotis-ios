//
//  File.swift
//  
//
//  Created by Garry on 30/01/23.
//

import Foundation

public struct RecommendDefaultUseCase: RecommendUseCase {
    
    private let repository: SearchRepository
    private let authRepository: AuthenticationRepository
    private let state = StateObservable.shared
    
    public init(
        repository: SearchRepository = SearchDefaultRepository(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
    ) {
        self.repository = repository
        self.authRepository = authRepository
    }
    
    public func execute(query: SearchQueryParam) async -> Result<[ReccomendData], Error> {
        do {
            var result = [ReccomendData]()
            
            let sess = try await (repository.provideGetSearchData(query: query).data ?? []).prefix(6)

            let user = try await (repository.provideGetRecommendation(query: query).data ?? []).prefix(6)
            
            result += user.compactMap {
                ReccomendData(name: $0.name.orEmpty(), type: .creator)
            }
            
            result += sess.compactMap {
                ReccomendData(name: $0.title.orEmpty(), type: .session)
            }
            
            return .success(result)
        } catch (let error as ErrorResponse) {
            if error.statusCode.orZero() == 401 {
                let result = await refreshToken()
                
                switch result {
                case .success(let token):
                    state.accessToken = token.accessToken.orEmpty()
                    state.refreshToken = token.refreshToken.orEmpty()
                    
                    let data = await execute(query: query)
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
