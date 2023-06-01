//
//  File.swift
//  
//
//  Created by Gus Adi on 30/05/23.
//

import Foundation

public struct CheckingVersionDefaultUseCase: CheckingVersionUseCase {
    
    private let repository: UtilsRepository
    
    public init(
        repository: UtilsRepository = UtilsDefaultRepository()
    ) {
        self.repository = repository
    }
    
    public func execute() async -> Result<VersionResponse, Error> {
        do {
            let data = try await repository.provideGetCurrentVersion()
            
            return .success(data)
        } catch (let error as ErrorResponse) {
            return .failure(error)
        } catch (let e) {
            return .failure(e)
        }
    }
}
