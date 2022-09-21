//
//  MeetingsDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 17/05/22.
//

import Foundation
import Combine

final class MeetingsDefaultRepository: MeetingsRepository {

	private let remote: MeetingsRemoteDataSource

	init(remote: MeetingsRemoteDataSource = MeetingsDefaultRemoteDataSource()) {
		self.remote = remote
	}

	func provideGetMeetingsRules() -> AnyPublisher<MeetingRulesResponse, UnauthResponse> {
		self.remote.getMeetingRules()
	}

	func provideSendQuestion(params: QuestionParams) -> AnyPublisher<QuestionResponse, UnauthResponse> {
		self.remote.sendQuestion(params: params)
	}

	func provideGetTalentMeeting(params: MeetingsParams) -> AnyPublisher<TalentMeeting, UnauthResponse> {
		self.remote.getTalentMeeting(params: params)
	}

	func provideGetTalentDetailMeeting(userID: String, params: MeetingsParams) -> AnyPublisher<TalentMeeting, UnauthResponse> {
		self.remote.getTalentDetailMeeting(userID: userID, params: params)
	}

	func providePatchEndMeeting(by meetingId: String) -> AnyPublisher<EditTalentResponse, UnauthResponse> {
		self.remote.patchEndMeeting(meetingId: meetingId)
	}

	func providePutEditMeeting(by meetingId: String) -> AnyPublisher<EditTalentResponse, UnauthResponse> {
		self.remote.putEditMeeting(meetingId: meetingId)
	}

	func provideDeleteMeeting(by meetingId: String) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		self.remote.deleteMeeting(meetingId: meetingId)
	}

	func providePostCheckMeetingEnd(meetingId: String) -> AnyPublisher<MeetingEndCheckResponse, UnauthResponse> {
		self.remote.postCheckMeetingEnd(meetingId: meetingId)
	}
}
