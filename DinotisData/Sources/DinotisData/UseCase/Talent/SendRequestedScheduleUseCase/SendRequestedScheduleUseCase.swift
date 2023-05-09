//
//  File 2.swift
//  
//
//  Created by Gus Adi on 22/04/23.
//

import Foundation

public protocol SendRequestedScheduleUseCase {
    func execute(with talentId: String, for body: SendScheduleRequest) async -> Result<RequestScheduleResponse, Error>
}
