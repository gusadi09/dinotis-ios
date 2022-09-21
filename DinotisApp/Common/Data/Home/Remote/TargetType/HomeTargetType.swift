//
//  HomeTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/04/22.
//

import Foundation
import Moya

enum HomeTargetType {
	case getFirstBanner
	case getSecondBanner
	case getDynamicHome
	case getPrivateCallFeature
	case getGroupCallFeature
	case getAnnouncementBanner
	case getLatestNotice
	case getOriginalSection
}

extension HomeTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		return [:]
	}
	
	var authorizationType: AuthorizationType? {
		return .bearer
	}
	
	var parameterEncoding: Moya.ParameterEncoding {
		return URLEncoding.default
	}
	
	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}
	
	var path: String {
		switch self {
		case .getFirstBanner:
			return "/home/first-banner"
		case .getSecondBanner:
			return "/home/second-banner"
		case .getDynamicHome:
			return "/home/talent-list/includes"
		case .getPrivateCallFeature:
			return "/home/feature/private"
		case .getAnnouncementBanner:
			return "/home/popup-banner"
		case .getLatestNotice:
			return "/notice/latest"
		case .getOriginalSection:
			return "/landing-page-list"
		case .getGroupCallFeature:
			return "/home/feature/group"
		}
	}
	
	var sampleData: Data {
		switch self {
		case .getFirstBanner:
			let response = BannerData(
				data: [
					Banner(
						id: 1,
						title: "Testing",
						url: "https://www.google.com",
						imgUrl: "https://www.google.com",
						caption: "Testing",
						description: "Testing",
						createdAt: Date().toString(format: .utc),
						updatedAt: Date().toString(format: .utc)
					)
				]
			)
			
			return response.toJSONData()
			
		case .getSecondBanner:
			let response = BannerData(
				data: [
					Banner(
						id: 1,
						title: "Testing",
						url: "https://www.google.com",
						imgUrl: "https://www.google.com",
						caption: "Testing",
						description: "Testing",
						createdAt: Date().toString(format: .utc),
						updatedAt: Date().toString(format: .utc)
					)
				]
			)
			
			return response.toJSONData()
			
		case .getDynamicHome:
			let response = DynamicHome(
				data: [
					DynamicHomeData(
						id: 1,
						name: "test",
						description: "test",
						createdAt: Date().toString(format: .utc),
						updatedAt: Date().toString(format: .utc),
						talentHomeTalentList: [
							TalentHomeData(
								id: 1,
								userId: "232b32h3b",
								homeTalentListId: 0,
								createdAt: Date().toString(format: .utc),
								updatedAt: Date().toString(format: .utc),
								user: nil
							)
						]
					)
				],
				nextCursor: 0
			)
			
			return response.toJSONData()
			
		case .getPrivateCallFeature:
			return Data()
		case .getAnnouncementBanner:
			let response = AnnouncementResponse(
				data: [
					AnnouncementData(
						id: 1,
						title: "UNITTEST",
						imgUrl: "UNITTEST",
						url: "UNITTEST",
						caption: "UNITTEST",
						description: "UNITTEST",
						createdAt: "UNITTEST",
						updatedAt: "UNITTEST"
					)
				],
				nextCursor: 0
			)

			return response.toJSONData()

		case .getLatestNotice:
			let response = LatestNoticeResponse(
				id: 1,
				url: "https://www.google.com",
				title: "UNITTEST",
				description: "UNITTEST",
				isActive: true,
				createdAt: Date().toString(format: .utcV2),
				updatedAt: Date().toString(format: .utcV2)
			)

			return response.toJSONData()
		case .getOriginalSection:
			let response = OriginalSectionResponse(
				data: [
					OriginalSectionData(
						id: 0,
						name: "unittest",
						isActive: true,
						landingPageListContentList: [
							LandingPageContentData(
								id: 0,
								userId: "unittest",
								meetingId: "unittest",
								landingPageListId: 0,
								user: User(
									id: "unittest",
									name: "unittest",
									username: "unittest",
									email: "unittest@mail.com",
									profilePhoto: "www.google.com",
									isVerified: false
								),
								meeting: UserMeeting(id: "unittest"),
								isActive: true,
								createdAt: Date().toString(format: .utc),
								updatedAt: Date().toString(format: .utc)
							)
						],
						user: User(
							id: "unittest",
							name: "unittest",
							username: "unittest",
							email: "unittest@mail.com",
							profilePhoto: "www.google.com",
							isVerified: false
						)
					)
				],
				nextCursor: 0
			)

			return response.toJSONData()
		case .getGroupCallFeature:
			return Data()
		}
	}
	
	var method: Moya.Method {
		return .get
	}
}
