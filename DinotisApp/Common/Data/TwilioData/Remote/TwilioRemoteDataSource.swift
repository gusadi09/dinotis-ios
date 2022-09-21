//
//  TwilioRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 09/08/22.
//

import Foundation
import Combine

protocol TwilioRemoteDataSource {
	func generateToken(on meetingId: String, withBody: Bool, body: GenerateTokenTwilioType) -> AnyPublisher<TwilioGeneratedTokenResponse, UnauthResponse>
	func syncRaiseHand(on meetingId: String, target body: SyncRaiseHandBody) -> AnyPublisher<InvitedResponse, UnauthResponse>
	func syncRemoveSpeaker(on meetingId: String, target body: SyncTwilioGeneralBody) -> AnyPublisher<RemovedSpeakerResponse, UnauthResponse>
	func syncSendSpeakerInvite(on meetingId: String, target body: SyncTwilioGeneralBody) -> AnyPublisher<InvitedResponse, UnauthResponse>
	func syncDeleteStream(on meetingId: String) -> AnyPublisher<DeletedRoomResponse, UnauthResponse>
	func syncViewerConnectedToPlayer(on meetingId: String, target body: SyncTwilioGeneralBody) -> AnyPublisher<InvitedResponse, UnauthResponse>
	func syncMuteAllParticipant(on meetingId: String, target body: SyncMuteAllBody) -> AnyPublisher<GeneralSuccessResponse, UnauthResponse>
	func syncSpotlightSpeaker(on meetingId: String, target body: SyncSpotlightSpeaker) -> AnyPublisher<GeneralSuccessResponse, UnauthResponse>
    func syncMoveAllToViewer(on meetingId: String) -> AnyPublisher<GeneralSuccessResponse, UnauthResponse>
    func privateGenerateToken(on meetingId: String) -> AnyPublisher<TwilioPrivateGeneratedTokenRespopnse, UnauthResponse>
	func privateDeleteStream(on meetingId: String) -> AnyPublisher<DeletedRoomResponse, UnauthResponse>
}
