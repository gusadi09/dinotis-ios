//
//  TwilioDataDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 09/08/22.
//

import Foundation
import Combine

final class TwilioDataDefaultRepository: TwilioDataRepository {
	
	private let remote: TwilioRemoteDataSource
	
	init(remote: TwilioRemoteDataSource = TwilioDefaultRemoteDataSource()) {
		self.remote = remote
	}
	
	func provideGenerateToken(on meetingId: String, withBody: Bool, body: GenerateTokenTwilioType) -> AnyPublisher<TwilioGeneratedTokenResponse, UnauthResponse> {
		remote.generateToken(on: meetingId, withBody: withBody, body: body)
	}
	
	func provideSyncRaiseHand(on meetingId: String, target body: SyncRaiseHandBody) -> AnyPublisher<InvitedResponse, UnauthResponse> {
		remote.syncRaiseHand(on: meetingId, target: body)
	}
	
	func provideSyncRemoveSpeaker(on meetingId: String, target body: SyncTwilioGeneralBody) -> AnyPublisher<RemovedSpeakerResponse, UnauthResponse> {
		remote.syncRemoveSpeaker(on: meetingId, target: body)
	}
	
	func provideSyncSendSpeakerInvite(on meetingId: String, target body: SyncTwilioGeneralBody) -> AnyPublisher<InvitedResponse, UnauthResponse> {
		remote.syncSendSpeakerInvite(on: meetingId, target: body)
	}
	
	func provideSyncDeleteStream(on meetingId: String) -> AnyPublisher<DeletedRoomResponse, UnauthResponse> {
		remote.syncDeleteStream(on: meetingId)
	}
	
	func provideSyncViewerConnectedToPlayer(on meetingId: String, target body: SyncTwilioGeneralBody) -> AnyPublisher<InvitedResponse, UnauthResponse> {
		remote.syncViewerConnectedToPlayer(on: meetingId, target: body)
	}
	
	func provideSyncMuteAllParticipant(on meetingId: String, target body: SyncMuteAllBody) -> AnyPublisher<GeneralSuccessResponse, UnauthResponse> {
		remote.syncMuteAllParticipant(on: meetingId, target: body)
	}
	
	func provideSyncSpotlightSpeaker(on meetingId: String, target body: SyncSpotlightSpeaker) -> AnyPublisher<GeneralSuccessResponse, UnauthResponse> {
		remote.syncSpotlightSpeaker(on: meetingId, target: body)
	}
    
    func provideSyncMoveAllToViewer(on meetingId: String) -> AnyPublisher<GeneralSuccessResponse, UnauthResponse> {
        remote.syncMoveAllToViewer(on: meetingId)
    }
    
    func providePrivateGenerateToken(on meetingId: String) -> AnyPublisher<TwilioPrivateGeneratedTokenRespopnse, UnauthResponse> {
        remote.privateGenerateToken(on: meetingId)
    }

	func providePrivateDeleteStream(on meetingId: String) -> AnyPublisher<DeletedRoomResponse, UnauthResponse> {
		remote.privateDeleteStream(on: meetingId)
	}
}
