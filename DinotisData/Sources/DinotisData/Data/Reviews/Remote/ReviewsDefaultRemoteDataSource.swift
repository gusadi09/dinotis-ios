//
//  File.swift
//  
//
//  Created by Gus Adi on 04/02/23.
//

import Foundation
import Moya

public final class ReviewsDefaultRemoteDataSource: ReviewsRemoteDataSource {

	private let provider: MoyaProvider<ReviewsTargetType>

	public init(provider: MoyaProvider<ReviewsTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	public func getReviews(with talentId: String, for params: GeneralParameterRequest) async throws -> ReviewsResponse {
		try await self.provider.request(.getReviews(talentId, params), model: ReviewsResponse.self)
	}
    
    public func giveReview(with body: ReviewRequestBody) async throws -> ReviewSuccessResponse {
        try await self.provider.request(.giveReview(body), model: ReviewSuccessResponse.self)
    }
}
