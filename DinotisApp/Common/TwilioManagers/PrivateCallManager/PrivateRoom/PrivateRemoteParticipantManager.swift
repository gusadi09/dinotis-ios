//
//  PrivateRemoteParticipantManager.swift
//  DinotisApp
//
//  Created by Garry on 08/09/22.
//

import TwilioVideo

protocol PrivateRemoteParticipantManagerDelegate: AnyObject {
    func participantDidChange(_ participant: PrivateRemoteParticipantManager)
    func participant(_ participant: PrivateRemoteParticipantManager, didSendMessage message: PrivateRoomMessage)
}

class PrivateRemoteParticipantManager: NSObject {
    var identity: String { participant.identity }
    var isMicOn: Bool {
        guard let track = participant.remoteAudioTracks.first else { return false }
        
        return track.isTrackSubscribed && track.isTrackEnabled
    }
    var cameraTrack: VideoTrack? {
        guard
            let publication = participant.remoteVideoTracks.first(where: { $0.trackName.contains(TrackName.camera) }),
            let track = publication.remoteTrack,
            track.isEnabled
        else {
            return nil
        }
        
        return track
    }
    private let participant: RemoteParticipant
    private weak var delegate: PrivateRemoteParticipantManagerDelegate?
    
    init(participant: RemoteParticipant, delegate: PrivateRemoteParticipantManagerDelegate) {
        self.participant = participant
        self.delegate = delegate
        super.init()
        participant.delegate = self
    }
}

extension PrivateRemoteParticipantManager: RemoteParticipantDelegate {
    func didSubscribeToVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        delegate?.participantDidChange(self)
    }
    
    func didUnsubscribeFromVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        delegate?.participantDidChange(self)
    }
    
    func remoteParticipantDidEnableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        delegate?.participantDidChange(self)
    }
    
    func remoteParticipantDidDisableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        delegate?.participantDidChange(self)
    }
    
    func didSubscribeToAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        delegate?.participantDidChange(self)
    }
    
    func didUnsubscribeFromAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        delegate?.participantDidChange(self)
    }
    
    func remoteParticipantDidEnableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        delegate?.participantDidChange(self)
    }
    
    func remoteParticipantDidDisableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        delegate?.participantDidChange(self)
    }
    
    func didSubscribeToDataTrack(
        dataTrack: RemoteDataTrack,
        publication: RemoteDataTrackPublication,
        participant: RemoteParticipant
    ) {
        dataTrack.delegate = self
    }
}

extension PrivateRemoteParticipantManager: RemoteDataTrackDelegate {
    func remoteDataTrackDidReceiveData(remoteDataTrack: RemoteDataTrack, message: Data) {
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard let message = try? decoder.decode(PrivateRoomMessage.self, from: message) else {
            return
        }
        
        delegate?.participant(self, didSendMessage: message)
    }
}

