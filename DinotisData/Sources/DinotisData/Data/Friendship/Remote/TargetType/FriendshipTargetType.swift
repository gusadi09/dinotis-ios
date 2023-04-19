//
//  FriendshipTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/12/22.
//

import Foundation
import Moya

public enum FriendshipTargetType {
	case getFollowedCreator(GeneralParameterRequest)
	case followCreator(String)
	case unfollowCreator(String)
}

extension FriendshipTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		switch self {
		case .getFollowedCreator(let param):
			return param.toJSON()
		case .followCreator(_):
			return [:]
		case .unfollowCreator(_):
			return [:]
		}
	}

	public var authorizationType: AuthorizationType? {
		return .bearer
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getFollowedCreator(_):
			return URLEncoding.default
		case .followCreator(_):
			return URLEncoding.default
		case .unfollowCreator(_):
			return URLEncoding.default
		}
	}

	public var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	public var path: String {
		switch self {
		case .getFollowedCreator(_):
			return "/friendships/followings"
		case .followCreator(let talentId):
			return "/friendships/\(talentId)/follow"
		case .unfollowCreator(let talentId):
			return "/friendships/\(talentId)/unfollow"
		}
	}

	public var method: Moya.Method {
		switch self {
		case .getFollowedCreator(_):
			return .get
		case .followCreator(_):
			return .post
		case .unfollowCreator(_):
			return .post
		}
	}
}
