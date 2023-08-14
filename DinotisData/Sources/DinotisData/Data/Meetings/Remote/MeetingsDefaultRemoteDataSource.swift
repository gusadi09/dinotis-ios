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
    
    public func addMeeting(with body: AddMeetingRequest) async throws -> MeetingDetailResponse {
        try await self.provider.request(.addMeeting(body), model: MeetingDetailResponse.self)
    }
    
    public func getTalentMeeting(params: MeetingsPageRequest) async throws -> TalentMeetingResponse {
        try await self.provider.request(.TalentMeeting(params), model: TalentMeetingResponse.self)
    }
    
    public func getTalentDetailMeeting(userID: String, params: MeetingsPageRequest) async throws -> TalentMeetingResponse {
        try await self.provider.request(.TalentDetailMeeting(userID, params), model: TalentMeetingResponse.self)
    }
    
    public func patchEndMeeting(meetingId: String) async throws -> MeetingDetailResponse {
        try await self.provider.request(.endMeeting(meetingId), model: MeetingDetailResponse.self)
    }
    
    public func putEditMeeting(meetingId: String, body: AddMeetingRequest) async throws -> MeetingDetailResponse {
        try await self.provider.request(.editMeeting(meetingId, body), model: MeetingDetailResponse.self)
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
    
    public func patchStartTalentMeeting(by meetingId: String) async throws -> MeetingDetailResponse {
        try await self.provider.request(.startMeeting(meetingId), model: MeetingDetailResponse.self)
    }
    
    public func getCollabMeeting(by meetingId: String) async throws -> MeetingDetailResponse {
        try await self.provider.request(.collaborationMeetingDetail(meetingId), model: MeetingDetailResponse.self)
    }
    
    public func approveInvitation(with isApprove: Bool, for meetingId: String) async throws -> SuccessResponse {
        try await self.provider.request(.approveInvitation(isApprove, meetingId), model: SuccessResponse.self)
    }
}
