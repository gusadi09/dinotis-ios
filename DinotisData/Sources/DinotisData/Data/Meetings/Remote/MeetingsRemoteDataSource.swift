//
//  File.swift
//  
//
//  Created by Gus Adi on 07/08/23.
//

import Foundation

protocol MeetingsRemoteDataSource {
    func getMeetingRules() async throws -> MeetingRulesResponse
    func addMeeting(with body: AddMeetingRequest) async throws -> MeetingDetailResponse
    func getTalentMeeting(params: MeetingsPageRequest) async throws -> TalentMeetingResponse
    func getTalentDetailMeeting(userID: String, params: MeetingsPageRequest) async throws -> TalentMeetingResponse
    func patchEndMeeting(meetingId: String) async throws -> MeetingDetailResponse
    func putEditMeeting(meetingId: String, body: AddMeetingRequest) async throws -> MeetingDetailResponse
    func deleteMeeting(meetingId: String) async throws -> SuccessResponse
    func postCheckMeetingEnd(meetingId: String) async throws -> CheckingEndMeetingResponse
    func getDetailMeeting(meetingId: String) async throws -> MeetingDetailResponse
    func patchStartTalentMeeting(by meetingId: String) async throws -> MeetingDetailResponse
    func getCollabMeeting(by meetingId: String) async throws -> MeetingDetailResponse
    func approveInvitation(with isApprove: Bool, for meetingId: String) async throws -> SuccessResponse
}
