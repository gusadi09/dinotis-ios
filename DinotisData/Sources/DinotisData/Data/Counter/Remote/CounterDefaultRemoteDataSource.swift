//
//  File.swift
//  
//
//  Created by Gus Adi on 21/03/23.
//

import Foundation
import Moya

public final class CounterDefaultRemoteDataSource: CounterRemoteDataSource {

    private let provider: MoyaProvider<CounterTargetType>

    public init(provider: MoyaProvider<CounterTargetType> = .defaultProvider()) {
        self.provider = provider
    }

    public func getCounter() async throws -> CounterResponse {
        try await self.provider.request(.getCounter, model: CounterResponse.self)
    }
}
