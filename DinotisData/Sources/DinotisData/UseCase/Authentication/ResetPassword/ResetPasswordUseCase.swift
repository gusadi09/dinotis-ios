//
//  File.swift
//  
//
//  Created by Gus Adi on 06/03/23.
//

import Foundation

public protocol ResetPasswordUseCase {
    func execute(with params: ResetPasswordRequest) async -> Result<UserResponse, Error>
}
