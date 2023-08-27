//
//  File.swift
//  
//
//  Created by Irham Naufal on 23/08/23.
//

import Foundation

public protocol GetBundlingDetailUseCase {
    func execute(by bundleId: String) async -> Result<DetailBundlingResponse, Error>
}
