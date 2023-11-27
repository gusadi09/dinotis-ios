//
//  File.swift
//  
//
//  Created by Gus Adi on 20/11/23.
//

import Foundation

public protocol PostCommentUseCase {
    func execute(for id: String, comment: String) async -> Result<String, Error>
}
