//
//  File.swift
//  
//
//  Created by Gus Adi on 20/01/23.
//

import Foundation

public struct LoginDefaultUseCase: LoginUseCase {
	private let repository: AuthenticationRepository
	private let state = StateObservable.shared

	public init(repository: AuthenticationRepository = AuthenticationDefaultRepository()) {
		self.repository = repository
	}
    
    @MainActor
    public func execute(by request: LoginRequest, type: UserType) async -> Result<LoginTokenData, Error> {
        do {
            let data = try await self.repository.login(with: request)
            
            state.userType = type.rawValue
            
            state.accessToken = (data.token?.accessToken).orEmpty()
            state.refreshToken = (data.token?.refreshToken).orEmpty()
            state.isVerified = "Verified"
            
            return .success(data.token ?? LoginTokenData(accessToken: nil, refreshToken: nil))
        } catch (let error as ErrorResponse) {
			return .failure(error)
		} catch (let e) {
			return .failure(e)
		}
	}
}
