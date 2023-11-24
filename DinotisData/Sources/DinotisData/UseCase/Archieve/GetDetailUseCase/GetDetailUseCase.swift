//
//  File.swift
//  
//
//  Created by Gus Adi on 15/11/23.
//

import Foundation

public protocol GetDetailVideoUseCase {
    func execute(for id: String) async -> Result<DetailVideosResponse, Error>
}
