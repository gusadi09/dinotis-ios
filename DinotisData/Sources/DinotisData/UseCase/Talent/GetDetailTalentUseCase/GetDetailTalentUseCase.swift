//
//  File 2.swift
//  
//
//  Created by Gus Adi on 22/04/23.
//

import Foundation

public protocol GetDetailTalentUseCase {
    func execute(query: String) async -> Result<TalentFromSearchResponse, Error>
}
