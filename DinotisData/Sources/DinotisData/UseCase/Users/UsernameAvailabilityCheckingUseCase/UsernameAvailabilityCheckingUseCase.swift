//
//  File.swift
//  
//
//  Created by Gus Adi on 09/03/23.
//

import Foundation

public protocol UsernameAvailabilityCheckingUseCase {
    func execute(with username: UsernameAvailabilityRequest) async -> Result<SuccessResponse, Error>
}
