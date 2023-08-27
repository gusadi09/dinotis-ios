//
//  File.swift
//  
//
//  Created by Irham Naufal on 23/08/23.
//

import Foundation

public protocol GetAvailableMeetingUseCase {
    func execute() async -> Result<AvailableMeetingResponse, Error>
}
