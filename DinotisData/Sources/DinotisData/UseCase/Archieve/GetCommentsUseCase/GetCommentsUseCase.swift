//
//  File.swift
//  
//
//  Created by Gus Adi on 20/11/23.
//

import Foundation

public protocol GetCommentsUseCase {
    func execute(for id: String, skip: Int, take: Int) async -> Result<CommentsResponse, Error>
}
