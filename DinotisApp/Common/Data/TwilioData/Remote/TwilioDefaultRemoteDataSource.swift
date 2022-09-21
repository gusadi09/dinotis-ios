//
//  TwilioDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 09/08/22.
//

import Foundation
import Combine
import Moya

final class TwilioDefaultRemoteDataSource: TwilioRemoteDataSource {
	
	private let provider: MoyaProvider<TwilioDataTargetType>
	
	init(provider: MoyaProvider<TwilioDataTargetType> = .defaultProvider()) {
		self.provider = provider
	}
	
	func generateToken(on meetingId: String, withBody: Bool, body: GenerateTokenTwilioType) -> AnyPublisher<TwilioGeneratedTokenResponse, UnauthResponse> {
		provider.request(.generateToken(meetingId, withBody, body), model: TwilioGeneratedTokenResponse.self)
	}
	
	func syncRaiseHand(on meetingId: String, target body: SyncRaiseHandBody) -> AnyPublisher<InvitedResponse, UnauthResponse> {
		provider.request(.syncRaiseHand(meetingId, body), model: InvitedResponse.self)
	}
	
	func syncRemoveSpeaker(on meetingId: String, target body: SyncTwilioGeneralBody) -> AnyPublisher<RemovedSpeakerResponse, UnauthResponse> {
		provider.request(.syncRemoveSpeaker(meetingId, body), model: RemovedSpeakerResponse.self)
	}
	
	func syncSendSpeakerInvite(on meetingId: String, target body: SyncTwilioGeneralBody) -> AnyPublisher<InvitedResponse, UnauthResponse> {
		provider.request(.syncSendSpeakerInvite(meetingId, body), model: InvitedResponse.self)
	}
	
	func syncDeleteStream(on meetingId: String) -> AnyPublisher<DeletedRoomResponse, UnauthResponse> {
		provider.request(.syncDeleteStream(meetingId), model: DeletedRoomResponse.self)
	}
	
	func syncViewerConnectedToPlayer(on meetingId: String, target body: SyncTwilioGeneralBody) -> AnyPublisher<InvitedResponse, UnauthResponse> {
		provider.request(.syncViewerConnectedToPlayer(meetingId, body), model: InvitedResponse.self)
	}
	
	func syncMuteAllParticipant(on meetingId: String, target body: SyncMuteAllBody) -> AnyPublisher<GeneralSuccessResponse, UnauthResponse> {
		provider.request(.syncMuteAllParticipant(meetingId, body), model: GeneralSuccessResponse.self)
	}
	
	func syncSpotlightSpeaker(on meetingId: String, target body: SyncSpotlightSpeaker) -> AnyPublisher<GeneralSuccessResponse, UnauthResponse> {
		provider.request(.syncSpotlightSpeaker(meetingId, body), model: GeneralSuccessResponse.self)
	}
    
    func syncMoveAllToViewer(on meetingId: String) -> AnyPublisher<GeneralSuccessResponse, UnauthResponse> {
        provider.request(.syncMoveAllToViewer(meetingId), model: GeneralSuccessResponse.self)
    }
    
    func privateGenerateToken(on meetingId: String) -> AnyPublisher<TwilioPrivateGeneratedTokenRespopnse, UnauthResponse> {
        provider.request(.privateGenerateToken(meetingId), model: TwilioPrivateGeneratedTokenRespopnse.self)
    }

	func privateDeleteStream(on meetingId: String) -> AnyPublisher<DeletedRoomResponse, UnauthResponse> {
		provider.request(.privateDeleteStream(meetingId), model: DeletedRoomResponse.self)
	}
}
