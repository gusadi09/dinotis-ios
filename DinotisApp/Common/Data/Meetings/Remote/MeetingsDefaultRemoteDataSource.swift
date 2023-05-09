//
//  MeetingsDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 17/05/22.
//

import Foundation
import Moya
import Combine

final class MeetingsDefaultRemoteDataSource: MeetingsRemoteDataSource {

    private let provider: MoyaProvider<MeetingsTargetType>

    init(provider: MoyaProvider<MeetingsTargetType> = .defaultProvider()) {
        self.provider = provider
    }

    func getMeetingRules() -> AnyPublisher<MeetingRulesResponse, UnauthResponse> {
        self.provider.request(.getRules, model: MeetingRulesResponse.self)
    }

    func sendQuestion(params: QuestionParams) -> AnyPublisher<QuestionResponse, UnauthResponse> {
        self.provider.request(.sendQuestion(params), model: QuestionResponse.self)
    }

    func getTalentMeeting(params: MeetingsParams) -> AnyPublisher<TalentMeeting, UnauthResponse> {
        self.provider.request(.TalentMeeting(params), model: TalentMeeting.self)
    }

    func getTalentDetailMeeting(userID: String, params: MeetingsParams) -> AnyPublisher<TalentMeeting, UnauthResponse> {
        self.provider.request(.TalentDetailMeeting(userID, params), model: TalentMeeting.self)
    }

    func patchEndMeeting(meetingId: String) -> AnyPublisher<EditTalentResponse, UnauthResponse> {
        self.provider.request(.endMeeting(meetingId), model: EditTalentResponse.self)
    }

	func putEditMeeting(meetingId: String, body: MeetingForm) -> AnyPublisher<EditTalentResponse, UnauthResponse> {
        self.provider.request(.editMeeting(meetingId, body), model: EditTalentResponse.self)
    }

    func deleteMeeting(meetingId: String) -> AnyPublisher<SuccessResponse, UnauthResponse> {
        self.provider.request(.deleteMeeting(meetingId), model: SuccessResponse.self)
    }

    func postCheckMeetingEnd(meetingId: String) -> AnyPublisher<MeetingEndCheckResponse, UnauthResponse> {
        self.provider.request(.checkMeetingEnd(meetingId), model: MeetingEndCheckResponse.self)
    }

    func getDetailMeeting(meetingId: String) -> AnyPublisher<DetailMeeting, UnauthResponse> {
        self.provider.request(.detailMeetings(meetingId), model: DetailMeeting.self)
    }

	func addMeeting(with body: MeetingForm) -> AnyPublisher<EditTalentResponse, UnauthResponse> {
		self.provider.request(.addMeeting(body), model: EditTalentResponse.self)
	}

	func patchStartTalentMeeting(by meetingId: String) -> AnyPublisher<EditTalentResponse, UnauthResponse> {
		self.provider.request(.startMeeting(meetingId), model: EditTalentResponse.self)
	}
    
    func getCollabMeeting(by meetingId: String) -> AnyPublisher<DetailMeeting, UnauthResponse> {
        self.provider.request(.collaborationMeetingDetail(meetingId), model: DetailMeeting.self)
    }
    
    func approveInvitation(with isApprove: Bool, for meetingId: String) -> AnyPublisher<SuccessResponse, UnauthResponse> {
        self.provider.request(.approveInvitation(isApprove, meetingId), model: SuccessResponse.self)
    }
}
