//
//  PrivateSpeakerSettingsManager.swift
//  DinotisApp
//
//  Created by Garry on 08/09/22.
//

import Combine
import Foundation

class PrivateSpeakerSettingsManager: ObservableObject {
    @Published var isMicOn = false {
        didSet {
            guard oldValue != isMicOn else { return }
            
            roomManager.localParticipant.isMicOn = isMicOn
        }
    }
    @Published var isRaiseHand = false
    @Published var isMuted = false
    
    @Published var isCameraOn = false {
        didSet {
            guard oldValue != isCameraOn else { return }
            
            roomManager.localParticipant.isCameraOn = isCameraOn
        }
    }
    private var roomManager: PrivateRoomManager!
    private var subscriptions = Set<AnyCancellable>()
    
    func configure(roomManager: PrivateRoomManager) {
        self.roomManager = roomManager
        
        roomManager.localParticipant.changePublisher
            .sink { [weak self] participant in
                self?.isMicOn = participant.isMicOn
                self?.isCameraOn = participant.isCameraOn
            }
            .store(in: &subscriptions)
        
        roomManager.messagePublisher
            .filter { $0.messageType == .mute && ($0.toParticipantIdentity == roomManager.localParticipant.identity || $0.toParticipantIdentity == "all") }
            .sink { [weak self] _ in
                if StateObservable.shared.twilioRole != "host" {
                    self?.isMicOn = false
                    self?.isMuted = true
                }
            }
            .store(in: &subscriptions)
    }
}
