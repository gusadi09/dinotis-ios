//
//  File.swift
//  
//
//  Created by Gus Adi on 15/11/23.
//

import Foundation

public protocol DeleteVideoUseCase {
    func execute(for id: String) async -> Result<SuccessResponse, Error>
}
