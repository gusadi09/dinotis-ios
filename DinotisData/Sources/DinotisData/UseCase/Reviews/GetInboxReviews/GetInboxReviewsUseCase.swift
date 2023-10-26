//
//  File.swift
//  
//
//  Created by Gus Adi on 10/10/23.
//

import Foundation

public protocol GetInboxReviewsUseCase {
    func execute(by filter: ReviewListFilterType) async -> Result<InboxReviewsResponse, Error>
}
