//
//  File.swift
//  
//
//  Created by Gus Adi on 07/08/23.
//

import Foundation

public protocol MeetingsRepository {
    func provideGetMeetingsRules() async throws -> MeetingRulesResponse
    func provideGetTalentMeeting(params: MeetingsPageRequest) async throws -> TalentMeetingResponse
    func provideGetTalentDetailMeeting(userID: String, params: MeetingsPageRequest) async throws -> TalentMeetingResponse
    func providePatchEndMeeting(meetingId: String) async throws -> MeetingDetailResponse
    func providePutEditMeeting(meetingId: String, body: AddMeetingRequest) async throws -> MeetingDetailResponse
    func provideDeleteMeeting(meetingId: String) async throws -> SuccessResponse
    func providePostCheckMeetingEnd(meetingId: String) async throws -> CheckingEndMeetingResponse
    func provideGetDetailMeeting(meetingId: String) async throws -> MeetingDetailResponse
    func provideAddMeeting(with body: AddMeetingRequest) async throws -> MeetingDetailResponse
    func providePatchStartTalentMeeting(by meetingId: String) async throws -> MeetingDetailResponse
    func provideGetCollabMeeting(by meetingId: String) async throws -> MeetingDetailResponse
    func provideApproveInvitation(with isApprove: Bool, for meetingId: String) async throws -> SuccessResponse
}
