//
//  Moya+RequestAsync.swift
//  DinotisApp
//
//  Created by Gus Adi on 12/02/22.
//

import Foundation
import Moya
import CombineMoya
import Combine

extension MoyaProvider {
	func request<T: Codable>(_ target: Target, model: T.Type) -> AnyPublisher<T, UnauthResponse> {
		self.requestPublisher(target)
			.mapError({ moyaError in
				return UnauthResponse(statusCode: moyaError.errorCode, message: moyaError.errorDescription, fields: nil, error: nil)
			})
			.flatMap({ (response) -> AnyPublisher<T, UnauthResponse> in
				let errorCode = response.statusCode
				let jsonDecoder = JSONDecoder()
				jsonDecoder.dateDecodingStrategy = .iso8601
				
				do {
					if errorCode == 200 || errorCode == 201 {
						let model = try jsonDecoder.decode(model.self, from: response.data)
						return Just(model).setFailureType(to: UnauthResponse.self).eraseToAnyPublisher()
					} else if errorCode == 204 {
						let model = SuccessResponse(message: "success")
						return Just((model as? T)!).setFailureType(to: UnauthResponse.self).eraseToAnyPublisher()
					} else {
						let errorResponse = try jsonDecoder.decode(UnauthResponse.self, from: response.data)
						return Fail(error: errorResponse).eraseToAnyPublisher()
					}
				} catch {
					let newsError = UnauthResponse(statusCode: 0, message: error.localizedDescription, fields: nil, error: nil)
					return Fail(error: newsError).eraseToAnyPublisher()
				}
			})
			.eraseToAnyPublisher()
	}
}
