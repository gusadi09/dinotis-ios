//
//  File.swift
//  
//
//  Created by Gus Adi on 09/03/23.
//

import Foundation

public protocol UsernameSuggestionUseCase {
    func execute(with suggest: UsernameSuggestionRequest) async -> Result<UsernameAvailabilityResponse, Error>
}
