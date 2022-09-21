//
//  PrivateStreamViewModel.swift
//  DinotisApp
//
//  Created by Garry on 08/09/22.
//

import Combine
import TwilioLivePlayer
import SwiftUI

class PrivateStreamViewModel: ObservableObject {
    enum AlertIdentifier: String, Identifiable {
        case error
		case streamEndedByHost
		case streamWillEndIfHostLeaves
        
        var id: String { rawValue }
    }
    
    @Published var alertIdentifier: AlertIdentifier?
    private(set) var error: Error?
    private var haveShownViewerConnectedAlert = false
    private var streamManager: PrivateStreamManager!
    private var speakerSettingsManager: PrivateSpeakerSettingsManager!
    private var subscriptions = Set<AnyCancellable>()
    let state = StateObservable.shared
    
    func configure(
        streamManager: PrivateStreamManager,
        speakerSettingsManager: PrivateSpeakerSettingsManager,
        meetingId: String
    ) {
        self.streamManager = streamManager
        self.speakerSettingsManager = speakerSettingsManager
        
        streamManager.$state
            .sink { [weak self] state in
                guard let self = self else {
                    return
                }
                
                switch state {
                case .connecting:
                    self.speakerSettingsManager.isMicOn = true
                    self.speakerSettingsManager.isCameraOn = true
                case .disconnected:
                    self.speakerSettingsManager.isMicOn = false
                    self.speakerSettingsManager.isCameraOn = false
                case .connected:
                    break
                }
            }
            .store(in: &subscriptions)
        
        streamManager.errorPublisher
            .sink { [weak self] error in self?.handleError(error, meetingId: meetingId) }
            .store(in: &subscriptions)
    }
    
    private func handleError(_ error: Error, meetingId: String) {
        streamManager.disconnect()
        self.error = error
        alertIdentifier = .error
    }
}
