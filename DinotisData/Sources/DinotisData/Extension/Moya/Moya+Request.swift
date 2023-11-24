//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation
import Moya

public extension MoyaProvider {
    func request<T: Codable>(_ target: Target, progress: ProgressBlock? = .none, model: T.Type, isSigned: Bool = false, isCancel: Bool = false) async throws -> T {
        return try await withCheckedThrowingContinuation({ continuation in
            if isCancel {
                self.session.session.invalidateAndCancel()
                if let decodedData = SuccessResponse(message: "CANCEL") as? T {
                    continuation.resume(returning: decodedData)
                } else {
                    let errorLocalized = ErrorResponse(statusCode: -1, message: "CANCEL", fields: nil, error: nil, errorCode: nil)
                    continuation.resume(throwing: errorLocalized)
                }
            } else {
                self.request(target, progress: progress) { result in
                    switch result {
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    case .success(let response):
                        let errorCode = response.statusCode
                        let jsonDecoder = JSONDecoder()
                        let formatter = DateFormatter()
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.dateFormat = DateFormatType.utc.rawValue
                        jsonDecoder.dateDecodingStrategy = .formatted(formatter)
                        
                        print("Response: ", String(data: response.data, encoding: .utf8))
                        
                        if response.statusCode >= 200 && response.statusCode < 299 && response.statusCode != 204 {
                            if isSigned {
                                if let decoded = "Success" as? T {
                                    continuation.resume(returning: decoded)
                                }
                            } else {
                                do {
                                    let decodedData = try jsonDecoder.decode(model.self, from: response.data)
                                    
                                    continuation.resume(returning: decodedData)
                                } catch (let error) {
                                    print(error)
                                    continuation.resume(throwing: error)
                                }
                            }
                        } else if response.statusCode == 204 {
                            if let decodedData = SuccessResponse(message: "Success") as? T {
                                continuation.resume(returning: decodedData)
                            } else {
                                let errorLocalized = ErrorResponse(statusCode: errorCode, message: LocalizationDataText.internalServerErrorText, fields: nil, error: nil, errorCode: nil)
                                continuation.resume(throwing: errorLocalized)
                            }
                        } else if response.statusCode >= 500 && response.statusCode <= 599 {
                            let errorLocalized = ErrorResponse(statusCode: errorCode, message: LocalizationDataText.internalServerErrorText, fields: nil, error: nil, errorCode: nil)
                            continuation.resume(throwing: errorLocalized)
                        } else {
                            do {
                                let decodedData = try jsonDecoder.decode(ErrorResponse.self, from: response.data)
                                
                                continuation.resume(throwing: decodedData)
                            } catch (let error) {
                                continuation.resume(throwing: error)
                            }
                        }
                    }
                }
            }
        })
    }
}
