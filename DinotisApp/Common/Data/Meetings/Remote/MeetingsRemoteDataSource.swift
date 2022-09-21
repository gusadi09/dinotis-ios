//
//  MeetingsRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 17/05/22.
//

import Foundation
import Combine

protocol MeetingsRemoteDataSource {
	func getMeetingRules() -> AnyPublisher<MeetingRulesResponse, UnauthResponse>
	func sendQuestion(params: QuestionParams) -> AnyPublisher<QuestionResponse, UnauthResponse>
	func getTalentMeeting(params: MeetingsParams) -> AnyPublisher<TalentMeeting, UnauthResponse>
	func getTalentDetailMeeting(userID: String, params: MeetingsParams) -> AnyPublisher<TalentMeeting, UnauthResponse>
	func patchEndMeeting(meetingId: String) -> AnyPublisher<EditTalentResponse, UnauthResponse>
	func putEditMeeting(meetingId: String) -> AnyPublisher<EditTalentResponse, UnauthResponse>
	func deleteMeeting(meetingId: String) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func postCheckMeetingEnd(meetingId: String) -> AnyPublisher<MeetingEndCheckResponse, UnauthResponse>
}
