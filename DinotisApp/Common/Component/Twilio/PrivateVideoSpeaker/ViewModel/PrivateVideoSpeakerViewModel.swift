//
//  PrivateVideoSpeakerViewModel.swift
//  DinotisApp
//
//  Created by Garry on 09/09/22.
//

import TwilioVideo
import Combine

/// Subscribes to room and participant state changes to provide speaker state for the UI to display in a grid
class PrivateVideoSpeakerViewModel: ObservableObject {
    @Published var localSpeaker = PrivateSpeakerVideoViewModel()
    @Published var remoteSpeakers = PrivateSpeakerVideoViewModel()
    @Published var isUpdated = false
    private let maxOnscreenSpeakerCount = 50
    private var roomManager: PrivateRoomManager!
    private var speakersMap: SyncUsersMap!
    @Published var speakerVideoViewModelFactory: PrivateSpeakerVideoViewModelFactory!
    private var subscriptions = Set<AnyCancellable>()
    
    func configure(
        roomManager: PrivateRoomManager,
        speakersMap: SyncUsersMap,
        speakerVideoViewModelFactory: PrivateSpeakerVideoViewModelFactory
    ) {
        self.roomManager = roomManager
        self.speakersMap = speakersMap
        self.speakerVideoViewModelFactory = speakerVideoViewModelFactory
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in
                guard let self = self, let remoteSpeakers = self.roomManager.remoteParticipants else { return }
                
                self.localSpeaker = self.speakerVideoViewModelFactory.makeSpeaker(participant: self.roomManager.localParticipant)
                
                self.remoteSpeakers = self.speakerVideoViewModelFactory.makeSpeaker(participant: remoteSpeakers)
                
                self.isUpdated = true
                
            }
            .store(in: &subscriptions)
        
        roomManager.roomDisconnectPublisher
            .sink { [weak self] _ in
                self?.localSpeaker = PrivateSpeakerVideoViewModel()
                self?.remoteSpeakers = PrivateSpeakerVideoViewModel()
            }
            .store(in: &subscriptions)
        
        roomManager.localParticipant.changePublisher
            .sink { [weak self] participant in
                
                guard let self = self else { return }
                
                self.localSpeaker = self.speakerVideoViewModelFactory.makeSpeaker(participant: participant)
                
            }
            .store(in: &subscriptions)
        
        roomManager.remoteParticipantConnectPublisher
            .sink { [weak self] participant in
                guard let self = self else { return }
                
                print("participant: ", participant)
                
                self.remoteSpeakers = self.speakerVideoViewModelFactory.makeSpeaker(participant: participant)
                
            }
            .store(in: &subscriptions)
        
        roomManager.remoteParticipantDisconnectPublisher
            .sink { [weak self] participant in  self?.remoteSpeakers = PrivateSpeakerVideoViewModel() }
            .store(in: &subscriptions)
        
        roomManager.remoteParticipantChangePublisher
            .sink { [weak self] participant in
                guard let self = self else { return }
                self.remoteSpeakers = self.speakerVideoViewModelFactory.makeSpeaker(participant: participant)
            }
            .store(in: &subscriptions)
    }
}


