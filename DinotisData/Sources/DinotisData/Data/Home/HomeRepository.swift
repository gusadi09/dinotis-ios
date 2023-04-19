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
	func provideGetPrivateCallFeature() async throws -> FeatureMeetingResponse
	func provideGetGroupCallFeature() async throws -> FeatureMeetingResponse
	func provideGetAnnouncementBanner() async throws -> AnnouncementResponse
	func provideGetLatestNotice() async throws -> LatestNoticesResponse
	func provideGetOriginalSection() async throws -> OriginalSectionResponse
}
