//
//  File.swift
//  
//
//  Created by Gus Adi on 14/11/23.
//

import Foundation

public struct PostVideoDefaultUseCase: PostVideoUseCase {

    private let repository: ArchieveRepository
    private let authRepository: AuthenticationRepository
    private let state = StateObservable.shared

    public init(
        repository: ArchieveRepository = ArchieveDefaultRepository(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
    ) {
        self.repository = repository
        self.authRepository = authRepository
    }

    public func execute(with body: VideosRequest) async -> Result<String, Error> {
        do {
            let data = try await repository.providePostVideo(body)

            return .success(data.id.orEmpty())
        } catch (let error as ErrorResponse) {
            if error.statusCode.orZero() == 401 {
                let result = await refreshToken()

                switch result {
                case .success(let token):
                    state.accessToken = token.accessToken.orEmpty()
                    state.refreshToken = token.refreshToken.orEmpty()

                    let data = await execute(with: body)
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
