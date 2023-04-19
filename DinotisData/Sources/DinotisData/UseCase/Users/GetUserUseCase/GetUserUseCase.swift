//
//  File.swift
//  
//
//  Created by Gus Adi on 09/03/23.
//

import Foundation

public protocol GetUserUseCase {
    func execute() async -> Result<UserResponse, Error>
}
