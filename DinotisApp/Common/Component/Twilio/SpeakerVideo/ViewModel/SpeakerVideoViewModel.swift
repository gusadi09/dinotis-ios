//
//  SpeakerVideoViewModel.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import TwilioVideo
import Foundation

/// Speaker abstraction so the UI can handle local and remote participants the same way.
struct SpeakerVideoViewModel {
	
	var identity = ""
	var displayName = ""
	var meetingId = ""
	var isYou = false
	var isMuted = false
	var dominantSpeakerStartTime: Date = .distantPast
	var isDominantSpeaker = false
	var cameraTrack: VideoTrack?
	var shouldMirrorCameraVideo = true
	var pinValue = 0
	
	init(meetingId: String, participant: LocalParticipantManager, isHost: Bool) {
		identity = participant.identity
		self.meetingId = meetingId
		displayName = DisplayNameFactory().makeDisplayName(identity: participant.identity, isHost: isHost, isYou: true)
		isYou = true
		isMuted = !participant.isMicOn
		
		if let cameraTrack = participant.cameraTrack, cameraTrack.isEnabled {
			self.cameraTrack = cameraTrack
		} else {
			cameraTrack = nil
		}
	}
	
	init(meetingId: String, participant: RemoteParticipantManager, isHost: Bool) {
		identity = participant.identity
		self.meetingId = meetingId
		displayName = DisplayNameFactory().makeDisplayName(identity: participant.identity, isHost: isHost, isYou: false)
		isMuted = !participant.isMicOn
		isYou = false
		isDominantSpeaker = participant.isDominantSpeaker
		dominantSpeakerStartTime = participant.dominantSpeakerStartTime
		cameraTrack = participant.cameraTrack
	}
	
}

extension SpeakerVideoViewModel: Hashable {
	static func == (lhs: SpeakerVideoViewModel, rhs: SpeakerVideoViewModel) -> Bool {
		lhs.identity == rhs.identity
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(identity)
	}
}

extension SpeakerVideoViewModel {
	init(
		identity: String = "",
		displayName: String? = nil,
		isYou: Bool = false,
		isMuted: Bool = false,
		isDominantSpeaker: Bool = false,
		dominantSpeakerTimestamp: Date = .distantPast,
		cameraTrack: VideoTrack? = nil,
		shouldMirrorCameraVideo: Bool = false
	) {
		self.identity = identity
		self.displayName = displayName ?? identity
		self.isYou = isYou
		self.isMuted = isMuted
		self.isDominantSpeaker = isDominantSpeaker
		self.dominantSpeakerStartTime = dominantSpeakerTimestamp
		self.cameraTrack = cameraTrack
		self.shouldMirrorCameraVideo = shouldMirrorCameraVideo
	}
}
