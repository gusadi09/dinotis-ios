//
//  File.swift
//  
//
//  Created by Gus Adi on 07/08/23.
//

import Foundation

final class MeetingsDefaultRepository: MeetingsRepository {
    
    private let remote: MeetingsRemoteDataSource
    
    init(remote: MeetingsRemoteDataSource = MeetingsDefaultRemoteDataSource()) {
        self.remote = remote
    }
    
    func provideGetMeetingsRules() async throws -> MeetingRulesResponse {
        try await self.remote.getMeetingRules()
    }
    
    func provideGetTalentMeeting(params: MeetingsPageRequest) async throws -> TalentMeetingResponse {
        try await self.remote.getTalentMeeting(params: params)
    }
    
    func provideGetTalentDetailMeeting(userID: String, params: MeetingsPageRequest) async throws -> TalentMeetingResponse {
        try await self.remote.getTalentDetailMeeting(userID: userID, params: params)
    }
    
    func providePatchEndMeeting(meetingId: String) async throws -> MeetingDetailResponse {
        try await self.remote.patchEndMeeting(meetingId: meetingId)
    }
    
    func providePutEditMeeting(meetingId: String, body: AddMeetingRequest) async throws -> MeetingDetailResponse {
        try await self.remote.putEditMeeting(meetingId: meetingId, body: body)
    }
    
    func provideDeleteMeeting(meetingId: String) async throws -> SuccessResponse {
        try await self.remote.deleteMeeting(meetingId: meetingId)
    }
    
    func providePostCheckMeetingEnd(meetingId: String) async throws -> CheckingEndMeetingResponse {
        try await self.remote.postCheckMeetingEnd(meetingId: meetingId)
    }
    
    func provideGetDetailMeeting(meetingId: String) async throws -> MeetingDetailResponse {
        try await self.remote.getDetailMeeting(meetingId: meetingId)
    }
    
    func provideAddMeeting(with body: AddMeetingRequest) async throws -> MeetingDetailResponse {
        try await self.remote.addMeeting(with: body)
    }
    
    func providePatchStartTalentMeeting(by meetingId: String) async throws -> MeetingDetailResponse {
        try await self.remote.patchStartTalentMeeting(by: meetingId)
    }
    
    func provideGetCollabMeeting(by meetingId: String) async throws -> MeetingDetailResponse {
        try await self.remote.getCollabMeeting(by: meetingId)
    }
    
    func provideApproveInvitation(with isApprove: Bool, for meetingId: String) async throws -> SuccessResponse {
        try await self.remote.approveInvitation(with: isApprove, for: meetingId)
    }
}
