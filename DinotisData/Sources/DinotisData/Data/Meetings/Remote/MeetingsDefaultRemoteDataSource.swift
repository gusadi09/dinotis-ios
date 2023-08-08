//
//  File.swift
//  
//
//  Created by Gus Adi on 07/08/23.
//

import Foundation
import Moya

final class MeetingsDefaultRemoteDataSource: MeetingsRemoteDataSource {
    
    private let provider: MoyaProvider<MeetingsTargetType>
    
    init(provider: MoyaProvider<MeetingsTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    func getMeetingRules() async throws -> MeetingRulesResponse {
        try await self.provider.request(.getRules, model: MeetingRulesResponse.self)
    }
    
    func addMeeting(with body: AddMeetingRequest) async throws -> MeetingDetailResponse {
        try await self.provider.request(.addMeeting(body), model: MeetingDetailResponse.self)
    }
    
    func getTalentMeeting(params: MeetingsPageRequest) async throws -> TalentMeetingResponse {
        try await self.provider.request(.TalentMeeting(params), model: TalentMeetingResponse.self)
    }
    
    func getTalentDetailMeeting(userID: String, params: MeetingsPageRequest) async throws -> TalentMeetingResponse {
        try await self.provider.request(.TalentDetailMeeting(userID, params), model: TalentMeetingResponse.self)
    }
    
    func patchEndMeeting(meetingId: String) async throws -> MeetingDetailResponse {
        try await self.provider.request(.endMeeting(meetingId), model: MeetingDetailResponse.self)
    }
    
    func putEditMeeting(meetingId: String, body: AddMeetingRequest) async throws -> MeetingDetailResponse {
        try await self.provider.request(.editMeeting(meetingId, body), model: MeetingDetailResponse.self)
    }
    
    func deleteMeeting(meetingId: String) async throws -> SuccessResponse {
        try await self.provider.request(.deleteMeeting(meetingId), model: SuccessResponse.self)
    }
    
    func postCheckMeetingEnd(meetingId: String) async throws -> CheckingEndMeetingResponse {
        try await self.provider.request(.checkMeetingEnd(meetingId), model: CheckingEndMeetingResponse.self)
    }
    
    func getDetailMeeting(meetingId: String) async throws -> MeetingDetailResponse {
        try await self.provider.request(.detailMeetings(meetingId), model: MeetingDetailResponse.self)
    }
    
    func patchStartTalentMeeting(by meetingId: String) async throws -> MeetingDetailResponse {
        try await self.provider.request(.startMeeting(meetingId), model: MeetingDetailResponse.self)
    }
    
    func getCollabMeeting(by meetingId: String) async throws -> MeetingDetailResponse {
        try await self.provider.request(.collaborationMeetingDetail(meetingId), model: MeetingDetailResponse.self)
    }
    
    func approveInvitation(with isApprove: Bool, for meetingId: String) async throws -> SuccessResponse {
        try await self.provider.request(.approveInvitation(isApprove, meetingId), model: SuccessResponse.self)
    }
}
