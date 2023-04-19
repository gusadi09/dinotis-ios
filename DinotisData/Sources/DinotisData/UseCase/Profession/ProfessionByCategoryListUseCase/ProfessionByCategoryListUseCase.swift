//
//  File.swift
//  
//
//  Created by Gus Adi on 13/03/23.
//

import Foundation

public protocol ProfessionByCategoryListUseCase {
    func execute(with categoryId: Int) async -> Result<ProfessionResponse, Error>
}
