//
//  HomeDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/04/22.
//

import Foundation
import Moya
import Combine

final class HomeDefaultRemoteDataSource: HomeRemoteDataSource {

	private let provider: MoyaProvider<HomeTargetType>
	
	init(provider: MoyaProvider<HomeTargetType> = .defaultProvider()) {
		self.provider = provider
	}
	
	func getFirstBanner() -> AnyPublisher<BannerData, UnauthResponse> {
		self.provider.request(.getFirstBanner, model: BannerData.self)
	}
	
	func getSecondBanner() -> AnyPublisher<BannerData, UnauthResponse> {
		self.provider.request(.getSecondBanner, model: BannerData.self)
	}
	
	func getDynamicHome() -> AnyPublisher<DynamicHome, UnauthResponse> {
		self.provider.request(.getDynamicHome, model: DynamicHome.self)
	}
	
	func getPrivateCallFeature() -> AnyPublisher<PrivateFeatureMeeting, UnauthResponse> {
		self.provider.request(.getPrivateCallFeature, model: PrivateFeatureMeeting.self)
	}

	func getAnnouncementBanner() -> AnyPublisher<AnnouncementResponse, UnauthResponse> {
		self.provider.request(.getAnnouncementBanner, model: AnnouncementResponse.self)
	}

	func getLatestNotice() -> AnyPublisher<LatestResponse, UnauthResponse> {
		self.provider.request(.getLatestNotice, model: LatestResponse.self)
	}

	func getOriginalSection() -> AnyPublisher<OriginalSectionResponse, UnauthResponse> {
		self.provider.request(.getOriginalSection, model: OriginalSectionResponse.self)
	}

	func getGroupCallFeature() -> AnyPublisher<PrivateFeatureMeeting, UnauthResponse> {
		self.provider.request(.getGroupCallFeature, model: PrivateFeatureMeeting.self)
	}
}
