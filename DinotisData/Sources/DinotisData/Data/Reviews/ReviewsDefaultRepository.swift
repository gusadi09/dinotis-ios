//
//  File.swift
//  
//
//  Created by Gus Adi on 04/02/23.
//

import Foundation

public final class ReviewsDefaultRepository: ReviewsRepository {

	private let remote: ReviewsRemoteDataSource

	public init(remote: ReviewsRemoteDataSource = ReviewsDefaultRemoteDataSource()) {
		self.remote = remote
	}

	public func provideGetReviews(by talentId: String, for params: GeneralParameterRequest) async throws -> ReviewsResponse {
		try await self.remote.getReviews(with: talentId, for: params)
	}
    
    public func provideGiveReview(with body: ReviewRequestBody) async throws -> ReviewSuccessResponse {
        try await self.remote.giveReview(with: body)
    }
    
    public func provideGetReasons(rating: Int?) async throws -> ReviewReasons {
        try await self.remote.getReasons(rating: rating)
    }
    
    public func provideGetTipAmounts() async throws -> TipAmounts {
        try await self.remote.getTipAmounts()
    }
}
