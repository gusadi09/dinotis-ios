//
//  File.swift
//  
//
//  Created by Gus Adi on 04/02/23.
//

import Foundation

public protocol ReviewsRepository {
    func provideGetInboxReviews(with filter: ReviewListFilterType) async throws -> InboxReviewsResponse
	func provideGetReviews(by talentId: String, for params: GeneralParameterRequest) async throws -> ReviewsResponse
    func provideGiveReview(with body: ReviewRequestBody) async throws -> ReviewSuccessResponse
    func provideGetReasons(rating: Int?) async throws -> ReviewReasons
    func provideGetTipAmounts() async throws -> TipAmounts
}
