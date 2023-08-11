//
//  File.swift
//  
//
//  Created by mora hakim on 09/08/23.
//

import Foundation

public class SendQuestionDefaultUseCase: SendQuestionUseCase {
    
    public let questionDataSource: QuestionRemoteDataSource
    public let authRepository: AuthenticationRepository
    public let state = StateObservable.shared

    public init(
        questionDataSource: QuestionRemoteDataSource = QuestionDefaultRemoteDataSource(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
    ) {
        self.questionDataSource = questionDataSource
        self.authRepository = authRepository
    }
    
    public func execute(params: QuestionRequest) async -> Result<QuestionData, Error> {
            do {
                let response = try await questionDataSource.sendQuestion(params: params)
                return .success(response)
            } catch let error as ErrorResponse {
                if error.statusCode.orZero() == 401 {
                    let result = await refreshToken()
                    
                    switch result {
                    case .success:
                        let refreshedResponse = await execute(params: params)
                        return refreshedResponse
                    case .failure(let error):
                        return .failure(error)
                    }
                } else {
                    return .failure(error)
                }
            } catch {
                return .failure(error)
            }
        }
        
        private func refreshToken() async -> Result<LoginTokenData, Error> {
            do {
                let data = try await authRepository.refreshToken()
                return .success(data)
            } catch let error as ErrorResponse {
                return .failure(error)
            } catch {
                return .failure(error)
            }
        }
}
