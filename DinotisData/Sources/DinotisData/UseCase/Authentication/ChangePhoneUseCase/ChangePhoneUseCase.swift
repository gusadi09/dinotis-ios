//
//  File.swift
//  
//
//  Created by Gus Adi on 07/03/23.
//

import Foundation

public protocol ChangePhoneUseCase {
    func execute(with params: OTPRequest) async -> Result<SuccessResponse, Error>
}
