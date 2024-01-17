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
	
    public func provideGetPrivateCallFeature(with request: FollowingContentRequest) async throws -> DataResponse<UserMeetingData> {
        try await self.remoteDataSource.getPrivateCallFeature(with: request)
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

    public func provideGetGroupCallFeature(with request: FollowingContentRequest) async throws -> DataResponse<UserMeetingData> {
        try await self.remoteDataSource.getGroupCallFeature(with: request)
	}
    
    public func provideGetRateCardList(with request: HomeContentRequest) async throws -> DataResponse<RateCardResponse> {
        try await self.remoteDataSource.getRateCardList(with: request)
    }
    
    public func provideGetAllSession(with request: HomeContentRequest) async throws -> DataResponse<MeetingDetailResponse> {
        try await self.remoteDataSource.getAllSession(with: request)
    }
    
    public func provideGetCreatorList(with request: HomeContentRequest) async throws -> DataResponse<TalentWithProfessionData> {
        try await self.remoteDataSource.getCreatorList(with: request)
    }
    
    public func provideGetVideoList(with request: FollowingContentRequest) async throws -> DataResponse<MineVideoData> {
        try await self.remoteDataSource.getVideoList(with: request)
    }
}
