//
//  File.swift
//  
//
//  Created by Gus Adi on 25/10/23.
//

import Foundation

public protocol GetMeetingFeeUseCase {
    func execute() async -> Result<Int, Error>
}
