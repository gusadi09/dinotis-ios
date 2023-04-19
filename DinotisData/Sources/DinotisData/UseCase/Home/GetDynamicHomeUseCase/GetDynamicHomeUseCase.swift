//
//  File.swift
//  
//
//  Created by Gus Adi on 30/03/23.
//

import Foundation

public protocol GetDynamicHomeUseCase {
    func execute() async -> Result<DynamicHomeResponse, Error>
}
