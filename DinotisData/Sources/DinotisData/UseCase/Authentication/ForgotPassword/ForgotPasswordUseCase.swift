//
//  File.swift
//  
//
//  Created by Gus Adi on 06/03/23.
//

import Foundation

public protocol ForgotPasswordUseCase {
    func execute(with params: OTPRequest) async -> Result<SuccessResponse, Error>
}
