//
//  GetFeatureVideoDefaultUseCase.swift
//
//
//  Created by Irham Naufal on 09/01/24.
//

import Foundation

public struct GetFeatureVideoDefaultUseCase: GetFeatureVideoUseCase {
    
    private let repository: HomeRepository
    private let authRepository: AuthenticationRepository
    private let state = StateObservable.shared

    public init(
        repository: HomeRepository = HomeDefaultRepository(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
    ) {
        self.repository = repository
        self.authRepository = authRepository
    }

    public func execute(with request: FollowingContentRequest) async -> Result<DataResponse<MineVideoData>, Error> {
        do {
            let data = try await repository.provideGetVideoList(with: request)

            return .success(data)
        } catch (let error as ErrorResponse) {
            if error.statusCode.orZero() == 401 {
                let result = await refreshToken()

                switch result {
                case .success(let token):
                    await state.setToken(token: token)

                    let data = await execute(with: request)
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
