//
//  File.swift
//  
//
//  Created by Gus Adi on 08/03/23.
//

import Foundation

public struct GetInvoiceDefaultUseCase: GetInvoiceUseCase {
    private let invoiceRepository: InvoiceRepository
    private let authRepository: AuthenticationRepository
    private let state = StateObservable.shared

    public init(
        invoiceRepository: InvoiceRepository = InvoiceDefaultRepository(),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository()
    ) {
        self.invoiceRepository = invoiceRepository
        self.authRepository = authRepository
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

    public func execute(by bookingID: String) async -> Result<InvoiceResponse, Error> {
        do {
            let data = try await invoiceRepository.provideGetInvoice(by: bookingID)

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
                    state.accessToken = token.accessToken.orEmpty()
                    state.refreshToken = token.refreshToken.orEmpty()

                    let data = await execute(by: bookingID)

                    return data
                }
            } else {
                return .failure(error)
            }
        } catch (let e) {
            return .failure(e)
        }
    }
}
