//
//  File.swift
//  
//
//  Created by Gus Adi on 07/08/23.
//

import Foundation

public final class MeetingsDefaultRepository: MeetingsRepository {
    
    private let remote: MeetingsRemoteDataSource
    
    public init(remote: MeetingsRemoteDataSource = MeetingsDefaultRemoteDataSource()) {
        self.remote = remote
    }
    
    public func provideGetMeetingsRules() async throws -> MeetingRulesResponse {
        try await self.remote.getMeetingRules()
    }
    
    public func provideGetTalentMeeting(params: MeetingsPageRequest) async throws -> TalentMeetingResponse {
        try await self.remote.getTalentMeeting(params: params)
    }
    
    public func provideGetTalentMeetingWithStatus(params: MeetingsStatusPageRequest) async throws -> CreatorMeetingWithStatusResponse {
        try await self.remote.getTalentMeetingWithStatus(params: params)
    }
    
    public func provideGetTalentDetailMeeting(userID: String, params: MeetingsPageRequest) async throws -> TalentMeetingResponse {
        try await self.remote.getTalentDetailMeeting(userID: userID, params: params)
    }
    
    public func providePatchEndMeeting(meetingId: String) async throws -> StartCreatorMeetingResponse {
        try await self.remote.patchEndMeeting(meetingId: meetingId)
    }
    
    public func providePutEditMeeting(meetingId: String, body: AddMeetingRequest) async throws -> StartCreatorMeetingResponse {
        try await self.remote.putEditMeeting(meetingId: meetingId, body: body)
    }
    
    public func provideDeleteMeeting(meetingId: String) async throws -> SuccessResponse {
        try await self.remote.deleteMeeting(meetingId: meetingId)
    }
    
    public func providePostCheckMeetingEnd(meetingId: String) async throws -> CheckingEndMeetingResponse {
        try await self.remote.postCheckMeetingEnd(meetingId: meetingId)
    }
    
    public func provideGetDetailMeeting(meetingId: String) async throws -> MeetingDetailResponse {
        try await self.remote.getDetailMeeting(meetingId: meetingId)
    }
    
    public func provideAddMeeting(with body: AddMeetingRequest) async throws -> StartCreatorMeetingResponse {
        try await self.remote.addMeeting(with: body)
    }
    
    public func providePatchStartTalentMeeting(by meetingId: String) async throws -> StartCreatorMeetingResponse {
        try await self.remote.patchStartTalentMeeting(by: meetingId)
    }
    
    public func provideGetCollabMeeting(by meetingId: String) async throws -> MeetingDetailResponse {
        try await self.remote.getCollabMeeting(by: meetingId)
    }
    
    public func provideApproveInvitation(with isApprove: Bool, for meetingId: String) async throws -> SuccessResponse {
        try await self.remote.approveInvitation(with: isApprove, for: meetingId)
    }
    
    public func provideGetClosestSession() async throws -> ClosestMeetingResponse {
        try await self.remote.getClosestSession()
    }
    
    public func provideGetMeetingFee() async throws -> MeetingFeeResponse {
        try await self.remote.getMeetingFee()
    }
    
    public func provideGetRecordings(for meetingId: String) async throws -> RecordingResponse {
        try await self.remote.getRecordings(for: meetingId)
    }
}
