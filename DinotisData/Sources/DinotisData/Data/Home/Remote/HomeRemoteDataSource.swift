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
	func getPrivateCallFeature() async throws -> FeatureMeetingResponse
	func getGroupCallFeature() async throws -> FeatureMeetingResponse
	func getAnnouncementBanner() async throws -> AnnouncementResponse
	func getLatestNotice() async throws -> LatestNoticesResponse
	func getOriginalSection() async throws -> OriginalSectionResponse
}
