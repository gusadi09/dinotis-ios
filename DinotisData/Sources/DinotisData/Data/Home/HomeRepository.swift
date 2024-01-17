//
//  HomeRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/04/22.
//

import Foundation
import Combine

public protocol HomeRepository {
	func provideGetFirstBanner() async throws -> BannerResponse
	func provideGetSecondBanner() async throws -> BannerResponse
	func provideGetDynamicHome() async throws -> DynamicHomeResponse
	func provideGetPrivateCallFeature(with request: FollowingContentRequest) async throws -> DataResponse<UserMeetingData>
	func provideGetGroupCallFeature(with request: FollowingContentRequest) async throws -> DataResponse<UserMeetingData>
	func provideGetAnnouncementBanner() async throws -> AnnouncementResponse
	func provideGetLatestNotice() async throws -> LatestNoticesResponse
	func provideGetOriginalSection() async throws -> OriginalSectionResponse
    func provideGetRateCardList(with request: HomeContentRequest) async throws -> DataResponse<RateCardResponse>
    func provideGetAllSession(with request: HomeContentRequest) async throws -> DataResponse<MeetingDetailResponse>
    func provideGetCreatorList(with request: HomeContentRequest) async throws -> DataResponse<TalentWithProfessionData>
    func provideGetVideoList(with request: FollowingContentRequest) async throws -> DataResponse<MineVideoData>
}
