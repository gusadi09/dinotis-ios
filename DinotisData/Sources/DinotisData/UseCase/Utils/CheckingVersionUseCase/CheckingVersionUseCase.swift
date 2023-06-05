//
//  File.swift
//  
//
//  Created by Gus Adi on 30/05/23.
//

import Foundation

public protocol CheckingVersionUseCase {
    func execute() async -> Result<VersionResponse, Error>
}
