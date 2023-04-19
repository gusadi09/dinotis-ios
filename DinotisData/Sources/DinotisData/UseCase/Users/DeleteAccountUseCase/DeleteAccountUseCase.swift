//
//  File.swift
//  
//
//  Created by Gus Adi on 09/03/23.
//

import Foundation

public protocol DeleteAccountUseCase {
    func execute() async -> Result<SuccessResponse, Error>
}
