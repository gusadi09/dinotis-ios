//
//  File.swift
//  
//
//  Created by Gus Adi on 13/11/23.
//

import Foundation
import Moya

public struct DownloadVideoDefaultUseCase: DownloadVideoUseCase {

    private let repository: SignedURLRepository
    private let authRepository: AuthenticationRepository
    private let state = StateObservable.shared

    public init(
        repository: SignedURLRepository = SignedURLDefaultRepository(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
    ) {
        self.repository = repository
        self.authRepository = authRepository
    }

    public func execute(url: String, filename: String, isCancel: Bool, progress: ProgressBlock?) async -> Result<String, Error> {
        do {
            let data = try await repository.provideDownloadVideo(url: url, filename: filename, isCancel: isCancel, progress: progress)

            return .success(data)
        } catch (let error as ErrorResponse) {
            if error.statusCode.orZero() == 401 {
                let result = await refreshToken()

                switch result {
                case .success(let token):
                    state.accessToken = token.accessToken.orEmpty()
                    state.refreshToken = token.refreshToken.orEmpty()

                    let data = await execute(url: url, filename: filename, isCancel: isCancel, progress: progress)
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
