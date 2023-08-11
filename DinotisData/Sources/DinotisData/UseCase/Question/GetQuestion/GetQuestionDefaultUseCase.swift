//
//  File.swift
//  
//
//  Created by mora hakim on 09/08/23.
//

import Foundation

public class GetQuestionDefaultUseCase: GetQuestionUseCase {
    
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
    
    public func execute(for meetingId: String) async -> Result<QuestionResponse, Error> {
           do {
               let question = try await questionDataSource.getQuestion(meetingId: meetingId)
               return .success(question)
           } catch let error as ErrorResponse {
               if error.statusCode.orZero() == 401 {
                   let result = await refreshToken()
                   
                   switch result {
                   case .success:
                       let refreshedQuestionResult = await execute(for: meetingId)
                       return refreshedQuestionResult
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
