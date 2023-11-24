//
//  File.swift
//  
//
//  Created by Gus Adi on 07/08/23.
//

import Foundation
import Moya

public final class MeetingsDefaultRemoteDataSource: MeetingsRemoteDataSource {
    
    private let provider: MoyaProvider<MeetingsTargetType>
    
    public init(provider: MoyaProvider<MeetingsTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    public func getMeetingRules() async throws -> MeetingRulesResponse {
        try await self.provider.request(.getRules, model: MeetingRulesResponse.self)
    }
    
    public func addMeeting(with body: AddMeetingRequest) async throws -> StartCreatorMeetingResponse {
        try await self.provider.request(.addMeeting(body), model: StartCreatorMeetingResponse.self)
    }
    
    public func getTalentMeeting(params: MeetingsPageRequest) async throws -> TalentMeetingResponse {
        try await self.provider.request(.talentMeeting(params), model: TalentMeetingResponse.self)
    }
    
    public func getTalentMeetingWithStatus(params: MeetingsStatusPageRequest) async throws -> CreatorMeetingWithStatusResponse {
        try await self.provider.request(.talentMeetingWithStatus(params), model: CreatorMeetingWithStatusResponse.self)
    }
    
    public func getTalentDetailMeeting(userID: String, params: MeetingsPageRequest) async throws -> TalentMeetingResponse {
        try await self.provider.request(.talentDetailMeeting(userID, params), model: TalentMeetingResponse.self)
    }
    
    public func patchEndMeeting(meetingId: String) async throws -> StartCreatorMeetingResponse {
        try await self.provider.request(.endMeeting(meetingId), model: StartCreatorMeetingResponse.self)
    }
    
    public func putEditMeeting(meetingId: String, body: AddMeetingRequest) async throws -> StartCreatorMeetingResponse {
        try await self.provider.request(.editMeeting(meetingId, body), model: StartCreatorMeetingResponse.self)
    }
    
    public func deleteMeeting(meetingId: String) async throws -> SuccessResponse {
        try await self.provider.request(.deleteMeeting(meetingId), model: SuccessResponse.self)
    }
    
    public func postCheckMeetingEnd(meetingId: String) async throws -> CheckingEndMeetingResponse {
        try await self.provider.request(.checkMeetingEnd(meetingId), model: CheckingEndMeetingResponse.self)
    }
    
    public func getDetailMeeting(meetingId: String) async throws -> MeetingDetailResponse {
        try await self.provider.request(.detailMeetings(meetingId), model: MeetingDetailResponse.self)
    }
    
    public func patchStartTalentMeeting(by meetingId: String) async throws -> StartCreatorMeetingResponse {
        try await self.provider.request(.startMeeting(meetingId), model: StartCreatorMeetingResponse.self)
    }
    
    public func getCollabMeeting(by meetingId: String) async throws -> MeetingDetailResponse {
        try await self.provider.request(.collaborationMeetingDetail(meetingId), model: MeetingDetailResponse.self)
    }
    
    public func approveInvitation(with isApprove: Bool, for meetingId: String) async throws -> SuccessResponse {
        try await self.provider.request(.approveInvitation(isApprove, meetingId), model: SuccessResponse.self)
    }
    
    public func getClosestSession() async throws -> ClosestMeetingResponse {
        try await self.provider.request(.closestSession, model: ClosestMeetingResponse.self)
    }
    
    public func getMeetingFee() async throws -> MeetingFeeResponse {
        try await self.provider.request(.getMeetingFee, model: MeetingFeeResponse.self)
    }
    
    public func getRecordings(for meetingId: String) async throws -> RecordingResponse {
        try await self.provider.request(.getRecordings(meetingId), model: RecordingResponse.self)
    }
}
