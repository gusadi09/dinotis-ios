//
//  File.swift
//  
//
//  Created by Gus Adi on 22/03/23.
//

import Foundation

public protocol ReadByIdUseCase {
    func execute(by id: String) async -> Result<SuccessResponse, Error>
}
