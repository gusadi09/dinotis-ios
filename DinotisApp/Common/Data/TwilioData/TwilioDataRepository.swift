//
//  TwilioDataRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 09/08/22.
//

import Foundation
import Combine

protocol TwilioDataRepository {
	func provideGenerateToken(on meetingId: String, withBody: Bool, body: GenerateTokenTwilioType) -> AnyPublisher<TwilioGeneratedTokenResponse, UnauthResponse>
	func provideSyncRaiseHand(on meetingId: String, target body: SyncRaiseHandBody) -> AnyPublisher<InvitedResponse, UnauthResponse>
	func provideSyncRemoveSpeaker(on meetingId: String, target body: SyncTwilioGeneralBody) -> AnyPublisher<RemovedSpeakerResponse, UnauthResponse>
	func provideSyncSendSpeakerInvite(on meetingId: String, target body: SyncTwilioGeneralBody) -> AnyPublisher<InvitedResponse, UnauthResponse>
	func provideSyncDeleteStream(on meetingId: String) -> AnyPublisher<DeletedRoomResponse, UnauthResponse>
	func provideSyncViewerConnectedToPlayer(on meetingId: String, target body: SyncTwilioGeneralBody) -> AnyPublisher<InvitedResponse, UnauthResponse>
	func provideSyncMuteAllParticipant(on meetingId: String, target body: SyncMuteAllBody) -> AnyPublisher<GeneralSuccessResponse, UnauthResponse>
	func provideSyncSpotlightSpeaker(on meetingId: String, target body: SyncSpotlightSpeaker) -> AnyPublisher<GeneralSuccessResponse, UnauthResponse>
    func provideSyncMoveAllToViewer(on meetingId: String) -> AnyPublisher<GeneralSuccessResponse, UnauthResponse>
    func providePrivateGenerateToken(on meetingId: String) -> AnyPublisher<TwilioPrivateGeneratedTokenRespopnse, UnauthResponse>
	func providePrivateDeleteStream(on meetingId: String) -> AnyPublisher<DeletedRoomResponse, UnauthResponse>
}
