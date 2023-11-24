//
//  File.swift
//  
//
//  Created by Gus Adi on 21/11/23.
//

import Foundation

public protocol GetArchivedUseCase {
    func execute(skip: Int, take: Int) async -> Result<ArchivedResponse, Error>
}
