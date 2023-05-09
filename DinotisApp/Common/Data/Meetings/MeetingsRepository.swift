//
//  MeetingsRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 17/05/22.
//

import Foundation
import Combine

protocol MeetingsRepository {
    func provideGetMeetingsRules() -> AnyPublisher<MeetingRulesResponse, UnauthResponse>
    func provideSendQuestion(params: QuestionParams) -> AnyPublisher<QuestionResponse, UnauthResponse>
    func provideGetTalentMeeting(params: MeetingsParams) -> AnyPublisher<TalentMeeting, UnauthResponse>
    func provideGetTalentDetailMeeting(userID: String, params: MeetingsParams) -> AnyPublisher<TalentMeeting, UnauthResponse>
    func providePatchEndMeeting(by meetingId: String) -> AnyPublisher<EditTalentResponse, UnauthResponse>
	func providePutEditMeeting(by meetingId: String, contain body: MeetingForm) -> AnyPublisher<EditTalentResponse, UnauthResponse>
    func provideDeleteMeeting(by meetingId: String) -> AnyPublisher<SuccessResponse, UnauthResponse>
    func providePostCheckMeetingEnd(meetingId: String) -> AnyPublisher<MeetingEndCheckResponse, UnauthResponse>
    func provideGetDetailMeeting(meetingId: String) -> AnyPublisher<DetailMeeting, UnauthResponse>
	func provideAddMeeting(with body: MeetingForm) -> AnyPublisher<EditTalentResponse, UnauthResponse>
	func providePatchStartTalentMeeting(by meetingId: String) -> AnyPublisher<EditTalentResponse, UnauthResponse>
    func provideGetCollabMeeting(by meetingId: String) -> AnyPublisher<DetailMeeting, UnauthResponse>
    func provideApproveInvitation(with isApprove: Bool, for meetingId: String) -> AnyPublisher<SuccessResponse, UnauthResponse>
}
