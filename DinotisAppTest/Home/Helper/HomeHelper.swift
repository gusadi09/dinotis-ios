//
//  HomeHelper.swift
//  DinotisAppTest
//
//  Created by Gus Adi on 16/04/22.
//

import SwiftUI
import Moya
import Combine
@testable import DinotisApp

final class HomeHelper {
	
	private let stubProvider = MoyaProvider<HomeTargetType>(stubClosure: MoyaProvider.delayedStub(1.0), plugins: [NetworkLoggerPlugin()])
	
	private let endpointClosureError = { (target: HomeTargetType) -> Endpoint in
		return Endpoint(
			url: URL(target: target).absoluteString,
			sampleResponseClosure: {
				.networkResponse(
					401,
					UnauthResponse(
						statusCode: 401,
						message: "Unathorized",
						fields: nil,
						error: "Unathorized"
					).toJSONData())
			},
			method: target.method,
			task: target.task,
			httpHeaderFields: target.headers
		)
	}
	
	private var errorStubProvider: MoyaProvider<HomeTargetType> {
		return MoyaProvider<HomeTargetType>(endpointClosure: endpointClosureError, stubClosure: MoyaProvider.immediatelyStub)
	}
	
	func stubGetFirstBanner() -> AnyPublisher<BannerData, UnauthResponse> {
		self.stubProvider.request(.getFirstBanner, model: BannerData.self)
	}
	
	func errorStubFirstBanner() -> AnyPublisher<BannerData, UnauthResponse> {
		self.errorStubProvider.request(.getFirstBanner, model: BannerData.self)
	}
	
	func stubGetSecondBanner() -> AnyPublisher<BannerData, UnauthResponse> {
		self.stubProvider.request(.getSecondBanner, model: BannerData.self)
	}
	
	func errorStubSecondBanner() -> AnyPublisher<BannerData, UnauthResponse> {
		self.errorStubProvider.request(.getSecondBanner, model: BannerData.self)
	}
	
	func stubGetHomeDynamicList() -> AnyPublisher<DynamicHome, UnauthResponse> {
		self.stubProvider.request(.getDynamicHome, model: DynamicHome.self)
	}
	
	func errorStubHomeDynamicList() -> AnyPublisher<DynamicHome, UnauthResponse> {
		self.errorStubProvider.request(.getDynamicHome, model: DynamicHome.self)
	}

	func stubGetAnnouncement() -> AnyPublisher<AnnouncementResponse, UnauthResponse> {
		self.stubProvider.request(.getAnnouncementBanner, model: AnnouncementResponse.self)
	}

	func errorStubGetAnnouncement() -> AnyPublisher<AnnouncementResponse, UnauthResponse> {
		self.errorStubProvider.request(.getAnnouncementBanner, model: AnnouncementResponse.self)
	}
}
