//
//  File.swift
//  
//
//  Created by Gus Adi on 22/03/23.
//

import Foundation

public protocol GetCounterUseCase {
    func execute() async -> Result<CounterResponse, Error>
}
