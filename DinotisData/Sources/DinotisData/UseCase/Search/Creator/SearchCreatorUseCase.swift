//
//  File.swift
//  
//
//  Created by Garry on 30/01/23.
//

import Foundation

public protocol SearchCreatorUseCase {
    func execute(query: SearchQueryParam) async -> Result<SearchedResponse, Error>
}
