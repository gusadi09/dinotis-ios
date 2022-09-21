//
//  PrivateSpeakerVideoViewModelFactory.swift
//  DinotisApp
//
//  Created by Garry on 09/09/22.
//

import Foundation

class PrivateSpeakerVideoViewModelFactory {
    private var meetingId: String = ""
    
    func configure(meetingId: String) {
        self.meetingId = meetingId
    }
    
    func makeSpeaker(participant: PrivateLocalParticipantManager) -> PrivateSpeakerVideoViewModel {
        return PrivateSpeakerVideoViewModel(meetingId: meetingId, participant: participant, isHost: false)
    }
    
    func makeSpeaker(participant: PrivateRemoteParticipantManager) -> PrivateSpeakerVideoViewModel {
        return PrivateSpeakerVideoViewModel(meetingId: meetingId, participant: participant, isHost: false)
    }
}

