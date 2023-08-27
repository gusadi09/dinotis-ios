//
//  File.swift
//  
//
//  Created by Irham Naufal on 23/08/23.
//

import Foundation

public struct UpdateBundlingDefaultUseCase: UpdateBundlingUseCase {
    
    private let authRepository: AuthenticationRepository
    private let bundlingRepository: BundlingRepository
    private let state = StateObservable.shared
    
    public init(
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        bundlingRepository: BundlingRepository = BundlingDefaultRepository()) {
        self.authRepository = authRepository
        self.bundlingRepository = bundlingRepository
    }
    
    public func execute(by bundleId: String, body: UpdateBundlingBody) async -> Result<CreateBundlingResponse, Error> {
        do {
            let data = try await bundlingRepository.provideUpdateBundling(by: bundleId, body: body)

            return .success(data)
        } catch (let error as ErrorResponse) {
            if error.statusCode.orZero() == 401 {
                let result = await refreshToken()

                switch result {
                case .failure(let error):
                    if let e = error as? ErrorResponse {
                        return .failure(e)
                    } else {
                        return .failure(error)
                    }

                case .success(let token):
                    await state.setToken(token: token)

                    let data = await execute(by: bundleId, body: body)

                    return data
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
