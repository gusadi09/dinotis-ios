//
//  File 2.swift
//  
//
//  Created by Gus Adi on 22/04/23.
//

import Foundation

public protocol GetCrowdedTalentUseCase {
    func execute(query: TalentsRequest) async -> Result<SearchTalentResponse, Error>
}
