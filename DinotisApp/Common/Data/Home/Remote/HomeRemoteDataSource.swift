//
//  HomeRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/04/22.
//

import Foundation
import Combine

protocol HomeRemoteDataSource {
	func getFirstBanner() -> AnyPublisher<BannerData, UnauthResponse>
	func getSecondBanner() -> AnyPublisher<BannerData, UnauthResponse>
	func getDynamicHome() -> AnyPublisher<DynamicHome, UnauthResponse>
	func getPrivateCallFeature() -> AnyPublisher<PrivateFeatureMeeting, UnauthResponse>
	func getGroupCallFeature() -> AnyPublisher<PrivateFeatureMeeting, UnauthResponse>
	func getAnnouncementBanner() -> AnyPublisher<AnnouncementResponse, UnauthResponse>
	func getLatestNotice() -> AnyPublisher<LatestResponse, UnauthResponse>
	func getOriginalSection() -> AnyPublisher<OriginalSectionResponse, UnauthResponse>
}
