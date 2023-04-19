//
//  PrivateStreamManager.swift
//  DinotisApp
//
//  Created by Garry on 08/09/22.
//

import Combine
import TwilioLivePlayer
import Foundation
import DinotisData

final class PrivateStreamManager: ObservableObject {
    enum State {
        case disconnected
        case connecting
        case connected
    }
    
    let errorPublisher = PassthroughSubject<Error, Never>()
    @Published var state = State.disconnected
    @Published var player: Player?
    @Published var roomManager: PrivateRoomManager?
    private var accessToken: String?
    @Published var roomSID: String?
    private var subscriptions = Set<AnyCancellable>()
    @Published var meetingData: TwilioPrivateGeneratedTokenRespopnse?
    private let repository: TwilioDataRepository
    @Published var meetingId: String = ""
    
    @Published var isLoading = false
    let stateObservable = StateObservable.shared
    
    init(
        repository: TwilioDataRepository = TwilioDataDefaultRepository()
    ) {
        self.repository = repository
    }
    
    func configure(
        roomManager: PrivateRoomManager
    ) {
        self.roomManager = roomManager
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in
                self?.state = .connected
            }
            .store(in: &subscriptions)
        
        roomManager.roomDisconnectPublisher
            .sink { [weak self] error in
                guard let error = error else { return }
                
                self?.handleError(error)
            }
            .store(in: &subscriptions)
        
        roomManager.localParticipant.errorPublisher
            .sink { [weak self] error in self?.handleError(error) }
            .store(in: &subscriptions)
    }
    
    func connect(meetingId: String) {
        
        state = .connecting
        
        fetchAccessToken(meetingId: meetingId)
    }
    
    func disconnect() {
        roomManager?.disconnect()
        player = nil
        state = .disconnected
    }
    
    private func fetchAccessToken(meetingId: String) {
        repository.providePrivateGenerateToken(on: meetingId)
            .sink { result in
                switch result {
                case .failure(let error):
                    self.handleError(error)
                    
                case .finished:
                    break
                }
            } receiveValue: { response in
                self.meetingId = meetingId
                self.accessToken = response.token.orEmpty()
                self.roomSID = response.roomSid.orEmpty()
                self.stateObservable.twilioAccessToken = response.token.orEmpty()
                
                self.connectRoom(accessToken: response.token.orEmpty())
            }
            .store(in: &subscriptions)
    }
    
    private func connectRoom(accessToken: String) {
        switch stateObservable.twilioRole {
        default:
            roomManager?.connect(roomName: meetingId, accessToken: accessToken)
        }
    }
    
    private func handleError(_ error: Error) {
        disconnect()
        errorPublisher.send(error)
    }
}
