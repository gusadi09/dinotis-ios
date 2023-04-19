//
//  File.swift
//  
//
//  Created by Gus Adi on 06/03/23.
//

import Foundation

public protocol OTPForgotPasswordVerificationUseCase {
    func execute(with params: OTPVerificationRequest) async -> Result<ForgetPasswordOTPResponse, Error>
}
