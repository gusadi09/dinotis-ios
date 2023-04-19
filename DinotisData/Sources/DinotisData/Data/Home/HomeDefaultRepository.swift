//
//  HomeDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/04/22.
//

import Foundation
import Combine

public final class HomeDefaultRepository: HomeRepository {

	private let remoteDataSource: HomeRemoteDataSource
	
    public init(remoteDataSource: HomeRemoteDataSource = HomeDefaultRemoteDataSource()) {
		self.remoteDataSource = remoteDataSource
	}
	
    public func provideGetFirstBanner() async throws -> BannerResponse {
		try await self.remoteDataSource.getFirstBanner()
	}
	
    public func provideGetSecondBanner() async throws -> BannerResponse {
        try await self.remoteDataSource.getSecondBanner()
	}
	
    public func provideGetDynamicHome() async throws -> DynamicHomeResponse {
        try await self.remoteDataSource.getDynamicHome()
	}
	
    public func provideGetPrivateCallFeature() async throws -> FeatureMeetingResponse {
        try await self.remoteDataSource.getPrivateCallFeature()
	}

    public func provideGetAnnouncementBanner() async throws -> AnnouncementResponse {
        try await self.remoteDataSource.getAnnouncementBanner()
	}

    public func provideGetLatestNotice() async throws -> LatestNoticesResponse {
        try await self.remoteDataSource.getLatestNotice()
	}

    public func provideGetOriginalSection() async throws -> OriginalSectionResponse {
        try await self.remoteDataSource.getOriginalSection()
	}

    public func provideGetGroupCallFeature() async throws -> FeatureMeetingResponse {
        try await self.remoteDataSource.getGroupCallFeature()
	}
}
