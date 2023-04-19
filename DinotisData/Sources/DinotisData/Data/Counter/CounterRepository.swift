//
//  File.swift
//  
//
//  Created by Gus Adi on 21/03/23.
//

import Foundation

public protocol CounterRepository {
    func provideGetCounter() async throws -> CounterResponse
}
