//
//  HomeDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/04/22.
//

import Foundation
import Combine

final class HomeDefaultRepository: HomeRepository {

	private let remoteDataSource: HomeRemoteDataSource
	
	init(remoteDataSource: HomeRemoteDataSource = HomeDefaultRemoteDataSource()) {
		self.remoteDataSource = remoteDataSource
	}
	
	func provideGetFirstBanner() -> AnyPublisher<BannerData, UnauthResponse> {
		self.remoteDataSource.getFirstBanner()
	}
	
	func provideGetSecondBanner() -> AnyPublisher<BannerData, UnauthResponse> {
		self.remoteDataSource.getSecondBanner()
	}
	
	func provideGetDynamicHome() -> AnyPublisher<DynamicHome, UnauthResponse> {
		self.remoteDataSource.getDynamicHome()
	}
	
	func provideGetPrivateCallFeature() -> AnyPublisher<PrivateFeatureMeeting, UnauthResponse> {
		self.remoteDataSource.getPrivateCallFeature()
	}

	func provideGetAnnouncementBanner() -> AnyPublisher<AnnouncementResponse, UnauthResponse> {
		self.remoteDataSource.getAnnouncementBanner()
	}

	func provideGetLatestNotice() -> AnyPublisher<LatestResponse, UnauthResponse> {
		self.remoteDataSource.getLatestNotice()
	}

	func provideGetOriginalSection() -> AnyPublisher<OriginalSectionResponse, UnauthResponse> {
		self.remoteDataSource.getOriginalSection()
	}

	func provideGetGroupCallFeature() -> AnyPublisher<PrivateFeatureMeeting, UnauthResponse> {
		self.remoteDataSource.getGroupCallFeature()
	}
}
