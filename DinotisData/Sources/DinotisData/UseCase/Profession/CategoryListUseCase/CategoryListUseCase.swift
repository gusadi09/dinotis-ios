//
//  File.swift
//  
//
//  Created by Gus Adi on 13/03/23.
//

import Foundation

public protocol CategoryListUseCase {
    func execute() async -> Result<CategoriesResponse, Error>
}
