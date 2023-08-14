//
//  File.swift
//  
//
//  Created by Gus Adi on 08/08/23.
//

import Foundation

public protocol GetRulesUseCase {
    func execute() async -> Result<MeetingRulesResponse, Error>
}
