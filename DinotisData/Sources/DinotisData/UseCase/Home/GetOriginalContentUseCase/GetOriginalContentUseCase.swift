//
//  File.swift
//  
//
//  Created by Gus Adi on 30/03/23.
//

import Foundation

public protocol GetOriginalContentUseCase {
    func execute() async -> Result<OriginalSectionResponse, Error>
}
