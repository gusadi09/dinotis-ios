//
//  File.swift
//  
//
//  Created by Irham Naufal on 14/08/23.
//

import Foundation

public protocol GetReasonsUseCase {
    func execute(rating: Int?) async -> Result<ReviewReasons, Error>
}
