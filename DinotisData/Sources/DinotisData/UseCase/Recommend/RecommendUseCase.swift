//
//  File.swift
//  
//
//  Created by Garry on 30/01/23.
//

import Foundation

public protocol RecommendUseCase {
    func execute(query: SearchQueryParam) async -> Result<[ReccomendData], Error>
}
