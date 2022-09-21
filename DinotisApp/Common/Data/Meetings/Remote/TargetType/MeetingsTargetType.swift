//
//  MeetingsTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 17/05/22.
//

import Foundation
import Moya

struct MeetingsParams: Codable {
	var take: Int = 15
	var skip: Int = 0
	var isStarted: String = ""
	var isEnded: String = ""
	var isAvailable: String = ""
}

enum MeetingsTargetType {
	case getRules
	case sendQuestion(QuestionParams)
	case TalentMeeting(MeetingsParams)
	case TalentDetailMeeting(String, MeetingsParams)
	case endMeeting(String)
	case editMeeting(String)
	case deleteMeeting(String)
	case checkMeetingEnd(String)
}

extension MeetingsTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		switch self {
		case .getRules:
			return[:]
		case .sendQuestion(let params):
			return params.toJSON()
		case .TalentMeeting(let params):
			return [
				"skip" : params.skip,
				"take" : params.take,
				"role" : 2,
				"is_available" : params.isAvailable,
				"is_ended" : params.isEnded
			]
		case .TalentDetailMeeting(_, let params):
			return [
				"skip" : params.skip,
				"take" : params.take,
				"is_available" : params.isAvailable,
				"is_ended" : params.isEnded
			]
		case .endMeeting(_):
			return [:]
		case .editMeeting(_):
			return [:]
		case .deleteMeeting(_):
			return [:]
		case .checkMeetingEnd(_):
			return [:]
		}
	}

	var authorizationType: AuthorizationType? {
		return .bearer
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getRules:
			return URLEncoding.default
		case .sendQuestion:
			return JSONEncoding.default
		case .TalentMeeting:
			return URLEncoding.default
		case .TalentDetailMeeting:
			return URLEncoding.default
		case .endMeeting(_):
			return URLEncoding.default
		case .editMeeting(_):
			return URLEncoding.default
		case .deleteMeeting(_):
			return URLEncoding.default
		case .checkMeetingEnd(_):
			return URLEncoding.default
		}
	}

	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	var path: String {
		switch self {
		case .getRules:
			return "/meetings/rules"
		case .sendQuestion:
			return "/questions"
		case .TalentMeeting:
			return "/meetings"
		case .TalentDetailMeeting(let userId, _):
			return "/meetings/\(userId)/talent"
		case .endMeeting(let meetingId):
			return "/meetings/\(meetingId)/end"
		case .editMeeting(let meetingId):
			return "/meetings/\(meetingId)"
		case .deleteMeeting(let meetingId):
			return "/meetings/\(meetingId)"
		case .checkMeetingEnd(let meetingId):
			return "/meetings/internal/check-end/\(meetingId)"
		}
	}

	var method: Moya.Method {
		switch self {
		case .getRules:
			return .get
		case .sendQuestion:
			return .post
		case .TalentMeeting:
			return .get
		case .TalentDetailMeeting:
			return .get
		case .endMeeting(_):
			return .patch
		case .editMeeting(_):
			return .put
		case .deleteMeeting(_):
			return .delete
		case .checkMeetingEnd(_):
			return .post
		}
	}
}
