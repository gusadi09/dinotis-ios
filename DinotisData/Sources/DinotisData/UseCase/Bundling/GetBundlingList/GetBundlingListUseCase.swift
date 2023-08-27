//
//  File.swift
//  
//
//  Created by Irham Naufal on 23/08/23.
//

import Foundation

public protocol GetBundlingListUseCase {
    func execute(query: BundlingListFilter) async -> Result<BundlingListResponse, Error>
}
