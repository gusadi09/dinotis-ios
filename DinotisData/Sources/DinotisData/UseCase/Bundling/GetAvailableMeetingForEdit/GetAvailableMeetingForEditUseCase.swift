//
//  File.swift
//  
//
//  Created by Irham Naufal on 23/08/23.
//

import Foundation

public protocol GetAvailableMeetingForEditUseCase {
    func execute(with bundleId: String) async -> Result<AvailableMeetingResponse, Error>
}
