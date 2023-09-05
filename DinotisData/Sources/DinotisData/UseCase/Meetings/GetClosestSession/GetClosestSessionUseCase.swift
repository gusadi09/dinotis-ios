//
//  File.swift
//  
//
//  Created by Gus Adi on 05/09/23.
//

import Foundation

public protocol GetClosestSessionUseCase {
    func execute() async -> Result<ClosestMeetingResponse, Error>
}
