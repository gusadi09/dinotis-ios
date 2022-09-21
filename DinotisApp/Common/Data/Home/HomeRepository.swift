//
//  HomeRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/04/22.
//

import Foundation
import Combine

protocol HomeRepository {
	func provideGetFirstBanner() -> AnyPublisher<BannerData, UnauthResponse>
	func provideGetSecondBanner() -> AnyPublisher<BannerData, UnauthResponse>
	func provideGetDynamicHome() -> AnyPublisher<DynamicHome, UnauthResponse>
	func provideGetPrivateCallFeature() -> AnyPublisher<PrivateFeatureMeeting, UnauthResponse>
	func provideGetGroupCallFeature() -> AnyPublisher<PrivateFeatureMeeting, UnauthResponse>
	func provideGetAnnouncementBanner() -> AnyPublisher<AnnouncementResponse, UnauthResponse>
	func provideGetLatestNotice() -> AnyPublisher<LatestResponse, UnauthResponse>
	func provideGetOriginalSection() -> AnyPublisher<OriginalSectionResponse, UnauthResponse>
}
