//
//  UsersTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import Moya

public enum UsersTargetType {
	case getUsers
	case updateUser(EditUserRequest)
	case usernameSuggest(UsernameSuggestionRequest)
	case usernameAvailability(UsernameAvailabilityRequest)
	case userCurrentBalance
	case updateImage(EditUserPhotoRequest)
	case deleteUser
    case creatorAvailability(CreatorAvailabilityRequest)
    case sendVerifRequest([String])
}

extension UsersTargetType: DinotisTargetType, AccessTokenAuthorizable {
    public var authorizationType: AuthorizationType? {
		switch self {
		case .getUsers:
			return .bearer
		case .updateUser:
			return .bearer
		case .usernameSuggest:
			return .bearer
		case .usernameAvailability:
			return .bearer
		case .userCurrentBalance:
			return .bearer
		case .updateImage:
			return .bearer
		case .deleteUser:
			return .bearer
        case .creatorAvailability(_):
            return .bearer
        case .sendVerifRequest(_):
            return .bearer
        }
	}
	
	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getUsers:
			return URLEncoding.default
		case .updateUser:
			return JSONEncoding.default
		case .usernameSuggest:
			return JSONEncoding.default
		case .usernameAvailability:
			return JSONEncoding.default
		case .userCurrentBalance:
			return URLEncoding.default
		case .updateImage:
			return JSONEncoding.default
		case .deleteUser:
			return URLEncoding.default
        case .creatorAvailability(_):
            return JSONEncoding.default
        case .sendVerifRequest(_):
            return JSONEncoding.default
        }
	}
	
    public var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}
	
	var parameters: [String : Any] {
		switch self {
		case .getUsers:
			return [:]
		case .updateUser(let params):
			return params.toJSON()
		case .usernameSuggest(let suggest):
			return suggest.toJSON()
		case .usernameAvailability(let username):
			return username.toJSON()
		case .userCurrentBalance:
			return [:]
		case .updateImage(let photoUrl):
			return photoUrl.toJSON()
		case .deleteUser:
			return [:]
        case .creatorAvailability(let req):
            return req.toJSON()
        case .sendVerifRequest(let links):
            return [
                "links": links
            ]
        }
	}
	
    public var path: String {
		switch self {
		case .getUsers:
			return "/users/me"
		case .updateUser:
			return "/users"
		case .usernameSuggest:
			return "/users/username/suggestion"
		case .usernameAvailability:
			return "/users/username/availability"
		case .userCurrentBalance:
			return "/balances/user/current"
		case .updateImage:
			return "/users/profile-photo"
		case .deleteUser:
			return "/users/me"
        case .creatorAvailability(_):
            return "/users/availability"
        case .sendVerifRequest(_):
            return "/users/request-verified"
        }
	}
	
    public var method:Moya.Method {
		switch self {
		case .getUsers:
			return .get
		case .updateUser:
			return .put
		case .usernameSuggest:
			return .post
		case .usernameAvailability:
			return .post
		case .userCurrentBalance:
			return .get
		case .updateImage:
			return .post
		case .deleteUser:
			return .delete
        case .creatorAvailability(_):
            return .post
        case .sendVerifRequest(_):
            return .post
        }
	}
}
