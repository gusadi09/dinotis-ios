//
//  Copyright (C) 2022 Twilio, Inc.
//

import Foundation

class SpeakerVideoViewModelFactory {
	private var speakersMap: SyncUsersMap!
	private var meetingId: String = ""
	
	func configure(meetingId: String, speakersMap: SyncUsersMap) {
		self.meetingId = meetingId
		self.speakersMap = speakersMap
	}
	
	func makeSpeaker(participant: LocalParticipantManager) -> SpeakerVideoViewModel {
		let isHost = speakersMap.host?.identity == participant.identity
		return SpeakerVideoViewModel(meetingId: meetingId, participant: participant, isHost: isHost)
	}
	
	func makeSpeaker(participant: RemoteParticipantManager) -> SpeakerVideoViewModel {
		let isHost = speakersMap.host?.identity == participant.identity
		return SpeakerVideoViewModel(meetingId: meetingId, participant: participant, isHost: isHost)
	}
}
