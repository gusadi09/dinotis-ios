//
//  File.swift
//  
//
//  Created by Irham Naufal on 23/08/23.
//

import Foundation

public protocol CreateBundlingUseCase {
    func execute(body: CreateBundling) async -> Result<CreateBundlingResponse, Error>
}
