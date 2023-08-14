//
//  File.swift
//  
//
//  Created by Gus Adi on 09/08/23.
//

import Foundation

public struct ApproveCollaborationInvitationDefaultUseCase: ApproveCollaborationInvitationUseCase {

    private let repository: MeetingsRepository
    private let authRepository: AuthenticationRepository
    private let state = StateObservable.shared

    public init(
        repository: MeetingsRepository = MeetingsDefaultRepository(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
    ) {
        self.repository = repository
        self.authRepository = authRepository
    }

    public func execute(_ isApprove: Bool, for meetingId: String) async -> Result<SuccessResponse, Error> {
        do {
            let data = try await repository.provideApproveInvitation(with: isApprove, for: meetingId)

            return .success(data)
        } catch (let error as ErrorResponse) {
            if error.statusCode.orZero() == 401 {
                let result = await refreshToken()

                switch result {
                case .success(let token):
                    await state.setToken(token: token)

                    let data = await execute(isApprove, for: meetingId)
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
