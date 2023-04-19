//
//  File.swift
//  
//
//  Created by Gus Adi on 06/03/23.
//

import Foundation

public protocol ChangePasswordUseCase {
    func execute(with params: ChangePasswordRequest) async -> Result<SuccessResponse, Error>
}
