//
//  File 2.swift
//  
//
//  Created by Gus Adi on 22/04/23.
//

import Foundation

public protocol GetReccomendationTalentUseCase {
    func execute(query: TalentsRequest) async -> Result<SearchTalentResponse, Error>
}
