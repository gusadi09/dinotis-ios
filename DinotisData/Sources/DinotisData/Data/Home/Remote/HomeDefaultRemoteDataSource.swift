//
//  HomeDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/04/22.
//

import Foundation
import Moya
import Combine

public final class HomeDefaultRemoteDataSource: HomeRemoteDataSource {

	private let provider: MoyaProvider<HomeTargetType>
	
	public init(provider: MoyaProvider<HomeTargetType> = .defaultProvider()) {
		self.provider = provider
	}
	
    public func getFirstBanner() async throws -> BannerResponse {
		try await self.provider.request(.getFirstBanner, model: BannerResponse.self)
	}
	
    public func getSecondBanner() async throws -> BannerResponse {
        try await self.provider.request(.getSecondBanner, model: BannerResponse.self)
	}
	
    public func getDynamicHome() async throws -> DynamicHomeResponse {
        try await self.provider.request(.getDynamicHome, model: DynamicHomeResponse.self)
	}
	
    public func getPrivateCallFeature() async throws -> FeatureMeetingResponse {
        try await self.provider.request(.getPrivateCallFeature, model: FeatureMeetingResponse.self)
	}

    public func getAnnouncementBanner() async throws -> AnnouncementResponse {
        try await self.provider.request(.getAnnouncementBanner, model: AnnouncementResponse.self)
	}

    public func getLatestNotice() async throws -> LatestNoticesResponse {
        try await self.provider.request(.getLatestNotice, model: LatestNoticesResponse.self)
	}

    public func getOriginalSection() async throws -> OriginalSectionResponse {
        try await self.provider.request(.getOriginalSection, model: OriginalSectionResponse.self)
	}

    public func getGroupCallFeature() async throws -> FeatureMeetingResponse {
        try await self.provider.request(.getGroupCallFeature, model: FeatureMeetingResponse.self)
	}
}
