//
//  File.swift
//  
//
//  Created by Irham Naufal on 10/02/23.
//

import Foundation

public protocol GiveReviewUseCase {
    func execute(with body: ReviewRequestBody) async -> Result<ReviewSuccessResponse, Error>
}
