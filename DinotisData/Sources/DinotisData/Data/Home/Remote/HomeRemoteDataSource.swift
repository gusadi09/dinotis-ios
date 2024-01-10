//
//  HomeRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/04/22.
//

import Foundation

public protocol HomeRemoteDataSource {
	func getFirstBanner() async throws -> BannerResponse
	func getSecondBanner() async throws -> BannerResponse
	func getDynamicHome() async throws -> DynamicHomeResponse
	func getPrivateCallFeature(with request: FollowingContentRequest) async throws -> DataResponse<UserMeetingData>
	func getGroupCallFeature(with request: FollowingContentRequest) async throws -> DataResponse<UserMeetingData>
	func getAnnouncementBanner() async throws -> AnnouncementResponse
	func getLatestNotice() async throws -> LatestNoticesResponse
	func getOriginalSection() async throws -> OriginalSectionResponse
    func getRateCardList(with request: HomeContentRequest) async throws -> DataResponse<RateCardResponse>
    func getAllSession(with request: HomeContentRequest) async throws -> DataResponse<MeetingDetailResponse>
    func getCreatorList(with request: HomeContentRequest) async throws -> DataResponse<TalentWithProfessionData>
    func getVideoList(with request: FollowingContentRequest) async throws -> DataResponse<MineVideoData>
}
