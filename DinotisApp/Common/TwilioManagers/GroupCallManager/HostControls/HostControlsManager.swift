//
//  HostControlsManager.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import Foundation
import Combine
import SwiftUI

final class HostControlsManager: ObservableObject {
	private var roomManager: RoomManager!
	@Published var meetingData: TwilioGeneratedTokenResponse?
	private let repository: TwilioDataRepository
	let state = StateObservable.shared
	var cancellables = Set<AnyCancellable>()
    
    enum LoadingState {
        case finished
        case removingAllParticipant
    }
    
    @Published var loadingState = LoadingState.finished
    @Published var isLoading = false
	
	init(repository: TwilioDataRepository = TwilioDataDefaultRepository()) {
		self.repository = repository
	}
	
	func configure(roomManager: RoomManager) {
		self.roomManager = roomManager
	}
	
	func muteSpeaker(identity: String) {
		let message = RoomMessage(messageType: .mute, toParticipantIdentity: identity)
		roomManager.localParticipant.sendMessage(message)
	}
	
	func removeSpeaker(on meetingId: String, by userIdentity: String) {
		
		let body = SyncTwilioGeneralBody(userIdentity: userIdentity)
		repository.provideSyncRemoveSpeaker(on: meetingId, target: body)
			.sink { _ in
				
			} receiveValue: { _ in
				
			}
			.store(in: &cancellables)
		
	}
    
    func moveAllToViewer(on meetingId: String) {
        withAnimation { [weak self] in
            self?.isLoading = true
            self?.loadingState = .removingAllParticipant
        }
        
        repository.provideSyncMoveAllToViewer(on: meetingId)
            .sink { [weak self] _ in
                withAnimation {
                    self?.isLoading = false
                    self?.loadingState = .finished
                }
            } receiveValue: { [weak self] _ in
                withAnimation {
                    self?.isLoading = false
                    self?.loadingState = .finished
                }
            }
            .store(in: &cancellables)

    }
	
	func spotlightSpeaker(on meetingId: String, by body: SyncSpotlightSpeaker, initState: @escaping () -> Void, finalState: @escaping () -> Void) {
		initState()
		
		repository.provideSyncSpotlightSpeaker(on: meetingId, target: body)
			.sink { _ in
				
			} receiveValue: { _ in
				finalState()
			}
			.store(in: &cancellables)
		
	}
	
	func removeSpeakerFromRoom(on meetingId: String, by userIdentity: String) {
		let message = RoomMessage(messageType: .remove, toParticipantIdentity: userIdentity)
		roomManager.localParticipant.sendMessage(message)
		removeSpeaker(on: meetingId, by: userIdentity)
	}
}

