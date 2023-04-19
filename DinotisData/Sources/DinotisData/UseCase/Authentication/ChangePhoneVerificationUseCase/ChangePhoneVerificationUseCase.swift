//
//  File.swift
//  
//
//  Created by Gus Adi on 07/03/23.
//

import Foundation

public protocol ChangePhoneVerificationUseCase {
    func execute(with params: OTPVerificationRequest) async -> Result<UserResponse, Error>
}
