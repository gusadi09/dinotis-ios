//
//  File.swift
//  
//
//  Created by Gus Adi on 07/08/23.
//

import Foundation
import Moya

public enum MeetingsTargetType {
    case getRules
    case addMeeting(AddMeetingRequest)
    case TalentMeeting(MeetingsPageRequest)
    case TalentDetailMeeting(String, MeetingsPageRequest)
    case detailMeetings(String)
    case endMeeting(String)
    case startMeeting(String)
    case editMeeting(String, AddMeetingRequest)
    case deleteMeeting(String)
    case checkMeetingEnd(String)
    case collaborationMeetingDetail(String)
    case approveInvitation(Bool, String)
}

extension MeetingsTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .getRules:
            return [
                "lang": (Locale.current.languageCode) ?? "id"
            ]
        case .addMeeting(let body):
            return body.toJSON()
        case .TalentMeeting(let params):
            if params.isAvailable.isEmpty && !params.isEnded.isEmpty {
                return [
                    "skip" : params.skip,
                    "take" : params.take,
                    "role" : 2,
                    "is_ended" : params.isEnded
                ]
            } else if params.isEnded.isEmpty && !params.isAvailable.isEmpty {
                return [
                    "skip" : params.skip,
                    "take" : params.take,
                    "role" : 2,
                    "is_available" : params.isAvailable
                ]
            } else if params.isEnded.isEmpty && params.isAvailable.isEmpty {
                return [
                    "skip" : params.skip,
                    "take" : params.take,
                    "role" : 2
                ]
            } else {
                return [
                    "skip" : params.skip,
                    "take" : params.take,
                    "role" : 2,
                    "is_available" : params.isAvailable,
                    "is_ended" : params.isEnded
                ]
            }

        case .TalentDetailMeeting(_, let params):
            if params.isAvailable.isEmpty && !params.isEnded.isEmpty {
                return [
                    "skip" : params.skip,
                    "take" : params.take,
                    "role" : 3,
                    "is_ended" : params.isEnded,
                    "lang": (Locale.current.languageCode) ?? "id"
                ]
            } else if params.isEnded.isEmpty && !params.isEnded.isEmpty {
                return [
                    "skip" : params.skip,
                    "take" : params.take,
                    "role" : 3,
                    "is_available" : params.isAvailable,
                    "lang": (Locale.current.languageCode) ?? "id"
                ]
            } else if params.isEnded.isEmpty && params.isAvailable.isEmpty {
                return [
                    "skip" : params.skip,
                    "take" : params.take,
                    "role" : 3,
                    "lang": (Locale.current.languageCode) ?? "id"
                ]
            } else {
                return [
                    "skip" : params.skip,
                    "take" : params.take,
                    "role" : 3,
                    "is_available" : params.isAvailable,
                    "is_ended" : params.isEnded,
                    "lang": (Locale.current.languageCode) ?? "id"
                ]
            }

        case .endMeeting(_):
            return [:]
        case .editMeeting(_, let body):
            return body.toJSON()
        case .deleteMeeting(_):
            return [:]
        case .checkMeetingEnd(_):
            return [:]
        case .detailMeetings(_):
            return [:]
        case .startMeeting(_):
            return [:]
        case .collaborationMeetingDetail(_):
            return [:]
        case .approveInvitation(let bool, _):
            return [
                "isApproved": bool
            ]
        }
    }

    public var authorizationType: AuthorizationType? {
        return .bearer
    }

    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .getRules:
            return URLEncoding.default
        case .TalentMeeting:
            return URLEncoding.default
        case .TalentDetailMeeting:
            return URLEncoding.default
        case .endMeeting(_):
            return URLEncoding.default
        case .editMeeting(_, _):
            return JSONEncoding.default
        case .deleteMeeting(_):
            return URLEncoding.default
        case .checkMeetingEnd(_):
            return URLEncoding.default
        case .detailMeetings(_):
            return URLEncoding.default
        case .addMeeting(_):
            return JSONEncoding.default
        case .startMeeting(_):
            return URLEncoding.default
        case .collaborationMeetingDetail(_):
            return URLEncoding.default
        case .approveInvitation(_, _):
            return JSONEncoding.default
        }
    }

    public var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }

    public var path: String {
        switch self {
        case .getRules:
            return "/meetings/rules"
        case .TalentMeeting:
            return "/meetings"
        case .TalentDetailMeeting(let userId, _):
            return "/meetings/\(userId)/talent/bookings"
        case .endMeeting(let meetingId):
            return "/meetings/\(meetingId)/end"
        case .editMeeting(let meetingId, _):
            return "/meetings/\(meetingId)"
        case .deleteMeeting(let meetingId):
            return "/meetings/\(meetingId)"
        case .checkMeetingEnd(let meetingId):
            return "/meetings/internal/check-end/\(meetingId)"
        case .detailMeetings(let meetingId):
            return "/meetings/\(meetingId)"
        case .addMeeting(_):
            return "/meetings"
        case .startMeeting(let meetingId):
            return "/meetings/\(meetingId)/start"
        case .collaborationMeetingDetail(let meetingId):
            return "/meetings/\(meetingId)/collaborations"
        case .approveInvitation(_, let string):
            return "/meetings/\(string)/collaboration/approve"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .getRules:
            return .get
        case .TalentMeeting:
            return .get
        case .TalentDetailMeeting:
            return .get
        case .endMeeting(_):
            return .patch
        case .editMeeting(_, _):
            return .put
        case .deleteMeeting(_):
            return .delete
        case .checkMeetingEnd(_):
            return .post
        case .detailMeetings(_):
            return .get
        case .addMeeting(_):
            return .post
        case .startMeeting(_):
            return .patch
        case .collaborationMeetingDetail(_):
            return .get
        case .approveInvitation(_, _):
            return .post
        }
    }
}
