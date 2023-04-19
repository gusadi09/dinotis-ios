//
//  File.swift
//  
//
//  Created by Gus Adi on 21/03/23.
//

import Foundation

public final class CounterDefaultRepository: CounterRepository {

    private let remote: CounterRemoteDataSource

    public init(remote: CounterRemoteDataSource = CounterDefaultRemoteDataSource()) {
        self.remote = remote
    }

    public func provideGetCounter() async throws -> CounterResponse {
        try await self.remote.getCounter()
    }
}
