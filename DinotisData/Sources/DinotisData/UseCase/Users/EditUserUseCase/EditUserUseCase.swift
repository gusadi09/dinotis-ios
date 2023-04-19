//
//  File.swift
//  
//
//  Created by Gus Adi on 09/03/23.
//

import Foundation

public protocol EditUserUseCase {
    func execute(with body: EditUserRequest) async -> Result<UserResponse, Error>
}
