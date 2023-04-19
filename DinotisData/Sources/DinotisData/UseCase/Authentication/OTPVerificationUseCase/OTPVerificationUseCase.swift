//
//  File.swift
//  
//
//  Created by Gus Adi on 07/03/23.
//

import Foundation

public protocol OTPVerificationUseCase {
    func execute(with params: OTPVerificationRequest) async -> Result<LoginTokenData, Error>
}
