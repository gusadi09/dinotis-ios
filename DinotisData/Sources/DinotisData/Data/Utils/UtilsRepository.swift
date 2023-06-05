//
//  File.swift
//  
//
//  Created by Gus Adi on 30/05/23.
//

import Foundation

public protocol UtilsRepository {
    func provideGetCurrentVersion() async throws -> VersionResponse
}
