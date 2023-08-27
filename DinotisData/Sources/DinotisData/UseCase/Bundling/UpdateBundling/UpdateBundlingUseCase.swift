//
//  File.swift
//  
//
//  Created by Irham Naufal on 23/08/23.
//

import Foundation

public protocol UpdateBundlingUseCase {
    func execute(by bundleId: String, body: UpdateBundlingBody) async -> Result<CreateBundlingResponse, Error>
}
