//
//  File.swift
//  
//
//  Created by Gus Adi on 04/02/23.
//

import Foundation

public protocol ReviewsRemoteDataSource {
    func getInboxReviews(filter: ReviewListFilterType) async throws -> InboxReviewsResponse
	func getReviews(with talentId: String, for params: GeneralParameterRequest) async throws -> ReviewsResponse
    func giveReview(with body: ReviewRequestBody) async throws -> ReviewSuccessResponse
    func getReasons(rating: Int?) async throws -> ReviewReasons
    func getTipAmounts() async throws -> TipAmounts
}
