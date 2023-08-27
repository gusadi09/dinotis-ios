//
//  File.swift
//  
//
//  Created by Irham Naufal on 23/08/23.
//

import Foundation

public protocol DeleteBundlingUseCase {
    func execute(by bundleId: String) async -> Result<CreateBundlingResponse, Error>
}
