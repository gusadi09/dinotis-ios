//
//  File.swift
//  
//
//  Created by Gus Adi on 25/01/23.
//

import Foundation

public struct RegisterDefaultUseCase: RegisterUseCase {

	private let repository: AuthenticationRepository
	private let state = StateObservable.shared

	public init(repository: AuthenticationRepository = AuthenticationDefaultRepository()) {
		self.repository = repository
	}

	public func execute(by request: OTPRequest) async -> Result<String, Error> {
		do {
			let data = try await self.repository.register(with: request)

			return .success(data.message.orEmpty())
		} catch (let error as ErrorResponse) {
			return .failure(error)
		} catch (let e) {
			return .failure(e)
		}
	}
}
