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
    func provideGetTalentMeetingWithStatus(params: MeetingsStatusPageRequest) async throws -> CreatorMeetingWithStatusResponse
    func providePatchEndMeeting(meetingId: String) async throws -> StartCreatorMeetingResponse
    func providePutEditMeeting(meetingId: String, body: AddMeetingRequest) async throws -> StartCreatorMeetingResponse
    func provideDeleteMeeting(meetingId: String) async throws -> SuccessResponse
    func providePostCheckMeetingEnd(meetingId: String) async throws -> CheckingEndMeetingResponse
    func provideGetDetailMeeting(meetingId: String) async throws -> MeetingDetailResponse
    func provideAddMeeting(with body: AddMeetingRequest) async throws -> StartCreatorMeetingResponse
    func providePatchStartTalentMeeting(by meetingId: String) async throws -> StartCreatorMeetingResponse
    func provideGetCollabMeeting(by meetingId: String) async throws -> MeetingDetailResponse
    func provideApproveInvitation(with isApprove: Bool, for meetingId: String) async throws -> SuccessResponse
    func provideGetClosestSession() async throws -> ClosestMeetingResponse
    func provideGetMeetingFee() async throws -> MeetingFeeResponse
    func provideGetRecordings(for meetingId: String) async throws -> RecordingResponse
}
