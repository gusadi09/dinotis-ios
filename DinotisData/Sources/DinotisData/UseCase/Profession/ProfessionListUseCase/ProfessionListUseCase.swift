//
//  File.swift
//  
//
//  Created by Gus Adi on 13/03/23.
//

import Foundation

public protocol ProfessionListUseCase {
    func execute() async -> Result<ProfessionResponse, Error>
}
