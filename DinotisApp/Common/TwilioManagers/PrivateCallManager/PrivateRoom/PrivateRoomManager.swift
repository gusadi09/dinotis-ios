//
//  PrivateRoomManager.swift
//  DinotisApp
//
//  Created by Garry on 08/09/22.
//

import Combine
import TwilioVideo

/// Configures the video room connection and uses publishers to notify subscribers of state changes.
class PrivateRoomManager: NSObject {
    // MARK: Publishers
    let roomConnectPublisher = PassthroughSubject<Void, Never>()
    let roomDisconnectPublisher = PassthroughSubject<Error?, Never>()
    let remoteParticipantConnectPublisher = PassthroughSubject<PrivateRemoteParticipantManager, Never>()
    let remoteParticipantDisconnectPublisher = PassthroughSubject<PrivateRemoteParticipantManager, Never>()
    
    let remoteParticipantChangePublisher = PassthroughSubject<PrivateRemoteParticipantManager, Never>()
    let messagePublisher = PassthroughSubject<PrivateRoomMessage, Never>()
    // MARK: -
    
    var roomSID: String? { room?.sid }
    var roomName: String? { room?.name }
    private(set) var localParticipant: PrivateLocalParticipantManager!
    private(set) var remoteParticipants: PrivateRemoteParticipantManager?
    private var room: Room?
    
    func configure(localParticipant: PrivateLocalParticipantManager) {
        self.localParticipant = localParticipant
    }
    
    func connect(roomName: String, accessToken: String) {
        let options = ConnectOptions(token: accessToken) { builder in
            builder.roomName = roomName
            builder.audioTracks = [self.localParticipant.micTrack].compactMap { $0 }
            builder.videoTracks = [self.localParticipant.cameraTrack].compactMap { $0 }
            builder.dataTracks = [self.localParticipant.dataTrack].compactMap { $0 }
            builder.isDominantSpeakerEnabled = true
            builder.bandwidthProfileOptions = BandwidthProfileOptions(
                videoOptions: VideoBandwidthProfileOptions { builder in
                    builder.mode = .grid
                    builder.dominantSpeakerPriority = .high
                }
            )
            builder.preferredVideoCodecs = [Vp8Codec(simulcast: true)]
        }
        
        room = TwilioVideoSDK.connect(options: options, delegate: self)
    }
    
    func disconnect() {
        cleanUp()
        roomDisconnectPublisher.send(nil)
    }
    
    private func cleanUp() {
        room?.disconnect()
        room = nil
        localParticipant.participant = nil
        remoteParticipants = nil
    }
    
    private func handleError(_ error: Error) {
        cleanUp()
        roomDisconnectPublisher.send(error)
    }
}

extension PrivateRoomManager: RoomDelegate {
    func roomDidConnect(room: Room) {
        localParticipant.participant = room.localParticipant
        remoteParticipants = room.remoteParticipants
            .filter { !$0.isVideoComposer }
            .map { PrivateRemoteParticipantManager(participant: $0, delegate: self) }
            .first
        roomConnectPublisher.send()
    }
    
    func roomDidFailToConnect(room: Room, error: Error) {
        handleError(error)
    }
    
    func roomDidDisconnect(room: Room, error: Error?) {
        if let error = error {
            if (error as NSError).isRoomCompletedError {
                handleError(LiveVideoError.streamEndedByHost)
            } else if (error as NSError).isParticipantNotFoundError {
                handleError(LiveVideoError.speakerMovedToViewersByHost)
            } else {
                handleError(error)
            }
        } else {
            handleError(LiveVideoError.speakerMovedToViewersByHost)
        }
    }
    
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        guard !participant.isVideoComposer else { return }
        
        let participant = PrivateRemoteParticipantManager(participant: participant, delegate: self)
        remoteParticipants = participant
        remoteParticipantConnectPublisher.send(participant)
    }
    
    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        guard let index = remoteParticipants else { return }
        
        remoteParticipantDisconnectPublisher.send(index)
    }
}

extension PrivateRoomManager: PrivateRemoteParticipantManagerDelegate {
    func participantDidChange(_ participant: PrivateRemoteParticipantManager) {
        remoteParticipantChangePublisher.send(participant)
    }
    
    func participant(_ participant: PrivateRemoteParticipantManager, didSendMessage message: PrivateRoomMessage) {
        messagePublisher.send(message)
    }
}

private extension NSError {
    var isRoomCompletedError: Bool {
        domain == TwilioVideoSDK.ErrorDomain && code == TwilioVideoSDK.Error.roomRoomCompletedError.rawValue
    }
    var isParticipantNotFoundError: Bool {
        domain == TwilioVideoSDK.ErrorDomain && code == TwilioVideoSDK.Error.participantNotFoundError.rawValue
    }
}

private extension RemoteParticipant {
    var isVideoComposer: Bool {
        identity.hasPrefix("video-composer")
    }
}

