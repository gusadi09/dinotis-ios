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

	func providePutEditMeeting(by meetingId: String, contain body: MeetingForm) -> AnyPublisher<EditTalentResponse, UnauthResponse> {
        self.remote.putEditMeeting(meetingId: meetingId, body: body)
    }

    func provideDeleteMeeting(by meetingId: String) -> AnyPublisher<SuccessResponse, UnauthResponse> {
        self.remote.deleteMeeting(meetingId: meetingId)
    }

    func providePostCheckMeetingEnd(meetingId: String) -> AnyPublisher<MeetingEndCheckResponse, UnauthResponse> {
        self.remote.postCheckMeetingEnd(meetingId: meetingId)
    }

    func provideGetDetailMeeting(meetingId: String) -> AnyPublisher<DetailMeeting, UnauthResponse> {
        self.remote.getDetailMeeting(meetingId: meetingId)
    }

	func provideAddMeeting(with body: MeetingForm) -> AnyPublisher<EditTalentResponse, UnauthResponse> {
		self.remote.addMeeting(with: body)
	}

	func providePatchStartTalentMeeting(by meetingId: String) -> AnyPublisher<EditTalentResponse, UnauthResponse> {
		self.remote.patchStartTalentMeeting(by: meetingId)
	}
    
    func provideGetCollabMeeting(by meetingId: String) -> AnyPublisher<DetailMeeting, UnauthResponse> {
        self.remote.getCollabMeeting(by: meetingId)
    }
    
    func provideApproveInvitation(with isApprove: Bool, for meetingId: String) -> AnyPublisher<SuccessResponse, UnauthResponse> {
        self.remote.approveInvitation(with: isApprove, for: meetingId)
    }
}
