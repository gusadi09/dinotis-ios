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
import DinotisDesignSystem

extension MoyaProvider {
	func request<T: Codable>(_ target: Target, model: T.Type) -> AnyPublisher<T, UnauthResponse> {
		self.requestPublisher(target)
			.mapError({ moyaError in
                return UnauthResponse(statusCode: moyaError.errorCode, message: moyaError.errorDescription, fields: nil, error: nil, errorCode: nil)
			})
			.flatMap({ (response) -> AnyPublisher<T, UnauthResponse> in
				let errorCode = response.statusCode
				let jsonDecoder = JSONDecoder()
				let formatter = DateFormatter()
				formatter.locale = Locale(identifier: "en_US_POSIX")
				formatter.dateFormat = DateFormat.utcV2.rawValue
				jsonDecoder.dateDecodingStrategy = .formatted(formatter)

				print("Moya v1: ", String(data: response.data, encoding: .utf8))
				
				do {
					if errorCode == 200 || errorCode == 201 {
						let model = try jsonDecoder.decode(model.self, from: response.data)
						return Just(model).setFailureType(to: UnauthResponse.self).eraseToAnyPublisher()
					} else if errorCode == 204 {
						let model = SuccessResponse(message: "success")
						return Just((model as? T)!).setFailureType(to: UnauthResponse.self).eraseToAnyPublisher()
					} else if errorCode >= 500 && errorCode <= 511 {
                        let errorLocalized = UnauthResponse(statusCode: errorCode, message: LocaleText.internalServerErrorText, fields: nil, error: nil, errorCode: nil)
						return Fail(error: errorLocalized).eraseToAnyPublisher()
					} else {
						let errorResponse = try jsonDecoder.decode(UnauthResponse.self, from: response.data)
						return Fail(error: errorResponse).eraseToAnyPublisher()
					}
				} catch {
                    print("parse error: ", error)
                    let errorLocalized = UnauthResponse(statusCode: 0, message: error.localizedDescription, fields: nil, error: nil, errorCode: nil)
					return Fail(error: errorLocalized).eraseToAnyPublisher()
				}
			})
			.eraseToAnyPublisher()
	}
}
