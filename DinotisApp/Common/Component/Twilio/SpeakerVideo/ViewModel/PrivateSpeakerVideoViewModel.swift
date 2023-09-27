//
//  PrivateSpeakerVideoViewModel.swift
//  DinotisApp
//
//  Created by Garry on 09/09/22.
//

import TwilioVideo
import Foundation

/// Speaker abstraction so the UI can handle local and remote participants the same way.
struct PrivateSpeakerVideoViewModel {
    
    var identity = ""
    var displayName = ""
    var meetingId = ""
    var isYou = false
    var isMuted = false
    var cameraTrack: VideoTrack?
    var shouldMirrorCameraVideo = true
    var pinValue = 0
    
    init(meetingId: String, participant: PrivateLocalParticipantManager, isHost: Bool) {
        identity = participant.identity
        self.meetingId = meetingId
        displayName = DisplayNameFactory().makeDisplayName(identity: participant.identity, isHost: isHost, isYou: true)
        isYou = true
        isMuted = !participant.isMicOn
        
        if let cameraTrack = participant.cameraTrack {
            self.cameraTrack = cameraTrack
        } else {
            cameraTrack = nil
        }
    }
    
    init(meetingId: String, participant: PrivateRemoteParticipantManager, isHost: Bool) {
        identity = participant.identity
        self.meetingId = meetingId
        displayName = DisplayNameFactory().makeDisplayName(identity: participant.identity, isHost: isHost, isYou: false)
        isMuted = !participant.isMicOn
        cameraTrack = participant.cameraTrack
    }
    
}

extension PrivateSpeakerVideoViewModel: Hashable {
    static func == (lhs: PrivateSpeakerVideoViewModel, rhs: PrivateSpeakerVideoViewModel) -> Bool {
        lhs.identity == rhs.identity
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }
}

extension PrivateSpeakerVideoViewModel {
    init(
        identity: String = "",
        displayName: String? = nil,
        isYou: Bool = false,
        isMuted: Bool = false,
        cameraTrack: VideoTrack? = nil,
        shouldMirrorCameraVideo: Bool = false
    ) {
        self.identity = identity
        self.displayName = displayName ?? identity
        self.isYou = isYou
        self.isMuted = isMuted
        self.cameraTrack = cameraTrack
        self.shouldMirrorCameraVideo = shouldMirrorCameraVideo
    }
}

