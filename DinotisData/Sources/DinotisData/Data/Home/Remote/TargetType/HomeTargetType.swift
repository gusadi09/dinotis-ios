//
//  HomeTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/04/22.
//

import Foundation
import Moya

public enum HomeTargetType {
	case getFirstBanner
	case getSecondBanner
	case getDynamicHome
	case getPrivateCallFeature(FollowingContentRequest)
	case getGroupCallFeature(FollowingContentRequest)
	case getAnnouncementBanner
	case getLatestNotice
	case getOriginalSection
    case getRateCardList(HomeContentRequest)
    case getAllSession(HomeContentRequest)
    case getCreatorList(HomeContentRequest)
    case getVideoList(FollowingContentRequest)
}

extension HomeTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
        switch self {
        case .getRateCardList(let request):
            return request.toJSON()
        case .getAllSession(let request):
            return request.toJSON()
        case .getCreatorList(let request):
            return request.toJSON()
        case .getVideoList(let request):
            return request.toJSON()
        case .getPrivateCallFeature(let request):
            return request.toJSON()
        case .getGroupCallFeature(let request):
            return request.toJSON()
        default:
            return [:]
        }
	}
	
    public var authorizationType: AuthorizationType? {
		return .bearer
	}
	
	var parameterEncoding: Moya.ParameterEncoding {
        return URLEncoding.default
	}
	
    public var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}
	
    public var path: String {
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
        case .getRateCardList:
            return "/home/feature/rate-card"
        case .getAllSession:
            return "/home/feature/all"
        case .getCreatorList:
            return "/talents"
        case .getVideoList:
            return "/home/feature/videos"
		}
	}
	
    public var sampleData: Data {
		switch self {
		case .getFirstBanner:
			let response = BannerResponse(
				data: [
					BannerData(
						id: 1,
						title: "Testing",
						url: "https://www.google.com",
						imgUrl: "https://www.google.com",
						caption: "Testing",
						description: "Testing",
						createdAt: Date(),
						updatedAt: Date()
					)
				]
			)
			
			return response.toJSONData()
			
		case .getSecondBanner:
			let response = BannerResponse(
				data: [
					BannerData(
						id: 1,
						title: "Testing",
						url: "https://www.google.com",
						imgUrl: "https://www.google.com",
						caption: "Testing",
						description: "Testing",
						createdAt: Date(),
						updatedAt: Date()
					)
				]
			)
			
			return response.toJSONData()
			
		case .getDynamicHome:
			let response = DynamicHomeResponse(
				data: [
					DynamicHomeData(
						id: 1,
						name: "test",
						description: "test",
						createdAt: Date(),
						updatedAt: Date(),
						talentHomeTalentList: [
							TalentHomeData(
								id: 1,
								userId: "232b32h3b",
								homeTalentListId: 0,
								createdAt: Date(),
								updatedAt: Date(),
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
						createdAt: Date(),
						updatedAt: Date()
					)
				],
				nextCursor: 0
			)

			return response.toJSONData()

		case .getLatestNotice:
			let response = LatestNoticeData(
				id: 1,
				url: "https://www.google.com",
				title: "UNITTEST",
				description: "UNITTEST",
				isActive: true,
				createdAt: Date(),
				updatedAt: Date()
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
                                user: UserResponse.sample,
								meeting: nil,
								isActive: true,
								createdAt: Date(),
								updatedAt: Date()
							)
						],
                        user: UserResponse.sample
					)
				],
				nextCursor: 0
			)

			return response.toJSONData()
		default:
            return Data()
		}
	}
	
    public var method: Moya.Method {
		return .get
	}
}
