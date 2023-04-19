//
//  File.swift
//  
//
//  Created by Gus Adi on 22/03/23.
//

import Foundation

public protocol ReadAllUseCase {
    func execute() async -> Result<SuccessResponse, Error>
}
