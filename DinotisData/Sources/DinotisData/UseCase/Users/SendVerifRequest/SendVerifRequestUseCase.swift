//
//  File.swift
//  
//
//  Created by Gus Adi on 13/02/24.
//

import Foundation

public protocol SendVerifRequestUseCase {
    func execute(with link: [String]) async -> Result<VerificationReqResponse, Error>
}
