//
//  File.swift
//  
//
//  Created by Gus Adi on 26/11/23.
//

import Foundation

public protocol SetCreatorAvailabilityUseCase {
    func execute(with body: CreatorAvailabilityRequest) async -> Result<String, Error>
}
