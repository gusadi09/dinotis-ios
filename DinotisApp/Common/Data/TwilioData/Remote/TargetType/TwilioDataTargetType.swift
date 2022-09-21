//
//  TwilioDataTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 09/08/22.
//

import Foundation
import Moya

struct SyncObjectNames: Codable {
	let speakersMap: String?
	let viewersMap: String?
	let raisedHandsMap: String?
	let userDocument: String?
	let roomDocument: String?
	
	enum CodingKeys: String, CodingKey {
		case speakersMap = "speakers_map"
		case viewersMap = "viewers_map"
		case raisedHandsMap = "raised_hands_map"
		case userDocument = "user_document"
		case roomDocument = "room_document"
	}
}

enum TwilioDataTargetType {
	case generateToken(String, Bool, GenerateTokenTwilioType)
	case syncRaiseHand(String, SyncRaiseHandBody)
	case syncRemoveSpeaker(String, SyncTwilioGeneralBody)
	case syncSendSpeakerInvite(String, SyncTwilioGeneralBody)
	case syncDeleteStream(String)
	case syncViewerConnectedToPlayer(String, SyncTwilioGeneralBody)
	case syncMuteAllParticipant(String, SyncMuteAllBody)
	case syncSpotlightSpeaker(String, SyncSpotlightSpeaker)
    case syncMoveAllToViewer(String)
    case privateGenerateToken(String)
	case privateDeleteStream(String)
}

extension TwilioDataTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var authorizationType: AuthorizationType? {
		return .bearer
	}
	
	var parameters: [String: Any] {
		switch self {
		case .generateToken(_, let isWithBody, let type):
			return isWithBody ? type.toJSON() : [:]
		case .syncRaiseHand(_, let syncRaiseHandBody):
			return syncRaiseHandBody.toJSON()
		case .syncRemoveSpeaker(_, let syncTwilioGeneralBody):
			return syncTwilioGeneralBody.toJSON()
		case .syncSendSpeakerInvite(_, let syncTwilioGeneralBody):
			return syncTwilioGeneralBody.toJSON()
		case .syncDeleteStream(_):
			return [:]
		case .syncViewerConnectedToPlayer(_, let syncTwilioGeneralBody):
			return syncTwilioGeneralBody.toJSON()
		case .syncMuteAllParticipant(_, let body):
			return body.toJSON()
		case .syncSpotlightSpeaker(_, let body):
			return body.toJSON()
        case .syncMoveAllToViewer(_):
            return [:]
        case .privateGenerateToken(_):
            return [:]
		case .privateDeleteStream:
			return [:]
		}
		
	}
	
	var path: String {
		switch self {
		case .generateToken(let string, _, _):
			return "/meetings/\(string)/twilio/token/generate"
		case .syncRaiseHand(let string, _):
			return "/meetings/\(string)/twilio/sync/raise-hand"
		case .syncRemoveSpeaker(let string, _):
			return "/meetings/\(string)/twilio/sync/remove-speaker"
		case .syncSendSpeakerInvite(let string, _):
			return "/meetings/\(string)/twilio/sync/send-speaker-invite"
		case .syncDeleteStream(let string):
			return "/meetings/\(string)/twilio/sync/delete-stream"
		case .syncViewerConnectedToPlayer(let string, _):
			return "/meetings/\(string)/twilio/sync/viewer-connected-to-player"
		case .syncMuteAllParticipant(let meetId, _):
			return "/meetings/\(meetId)/twilio/sync/mute-all-participants"
		case .syncSpotlightSpeaker(let meetId, _):
			return "/meetings/\(meetId)/twilio/sync/spotlight-speaker"
        case .syncMoveAllToViewer(let meetId):
            return "/meetings/\(meetId)/twilio/sync/move-all-to-viewer"
        case .privateGenerateToken(let string):
            return "/meetings/\(string)/twilio/private/token/generate"
		case .privateDeleteStream(let meetId):
			return "/meetings/\(meetId)/twilio/private/delete-stream"
		}
	}
	
	var method: Moya.Method {
		return .post
	}
	
	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .generateToken(_, let isWithBody, _):
			return isWithBody ? JSONEncoding.default : URLEncoding.default
		case .syncDeleteStream(_):
			return URLEncoding.default
        case .syncMoveAllToViewer(_):
            return URLEncoding.default
        case .privateGenerateToken(_):
            return URLEncoding.default
		default:
			return JSONEncoding.default
		}
	}
	
	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}
}
