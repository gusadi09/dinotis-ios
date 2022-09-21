//
//  MeetingRepo.swift
//  DinotisApp
//
//  Created by Gus Adi on 08/10/21.
//

import Foundation

class MeetingRepo {
	static let shared = MeetingRepo()
	
	var meetingId = ""
	
	var randomId = ""
	
	let baseUrl  = Configuration.shared.environment.baseURL
	
	var generateToken: URL {
		return URL(string: baseUrl + "/meetings/\(meetingId)/agora/token/generate/\(randomId)")!
	}
	
	var generateRtmToken: URL {
		return URL(string: baseUrl + "/meetings/\(meetingId)/agora/token/generate/\(randomId)/rtm")!
	}
	
	var addMeeting: URL {
		return URL(string: baseUrl + "/meetings")!
	}
	
	func getAllParticipant(with meetingId: String) -> URL {
		return URL(string: baseUrl + "/meetings/\(meetingId)/participants")!
	}
	
	func startMeeting(with meetingId: String) -> URL {
		return URL(string: baseUrl + "/meetings/\(meetingId)/start")!
	}
	
	func changedMeeting(meetingId: String) -> URL {
		return URL(string: baseUrl + "/meetings/\(meetingId)")!
	}
	
	func endMeeting(meetingId: String) -> URL {
		return URL(string: baseUrl + "/meetings/\(meetingId)/end")!
	}
}
