//
//  StreamManager.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import Combine
import TwilioLivePlayer
import Foundation
import FirebaseDatabase
import DinotisData

final class StreamManager: ObservableObject {
    enum State {
        case disconnected
        case connecting
        case connected
        case changingRole
    }
    
    struct ObjectNames {
        let speakersMap: String
        let viewersMap: String
        let raisedHandsMap: String
        let userDocument: String?
        let roomDocument: String?
    }
    
    let speakerLockAudio = PassthroughSubject<Bool, Never>()
    let spotlightedIdentity = PassthroughSubject<String, Never>()
    let hasNewQuestion = PassthroughSubject<Bool, Never>()
    let userSpeakerUpdatePublisher = PassthroughSubject<[SpeakerRealtimeResponse], Never>()
    let userUpdatePublisher = PassthroughSubject<[ViewerRealtimeResponse], Never>()
    let userRaiseHandUpdatePublisher = PassthroughSubject<[ViewerRealtimeResponse], Never>()
    let haveNewRaiseHand = PassthroughSubject<Bool, Never>()
    let speakerInvitePublisher = PassthroughSubject<Bool, Never>()
    let errorPublisher = PassthroughSubject<Error, Never>()
    @Published var viewerArrayRealtime = [ViewerRealtimeResponse]()
    @Published var speakerArrayRealtime = [SpeakerRealtimeResponse]()
    @Published var raiseHandArrayRealtime = [ViewerRealtimeResponse]()
    @Published var state = State.disconnected
    @Published var player: Player?
    @Published var isChatEnabled = true
    var config: StreamConfig!
    @Published var roomManager: RoomManager!
    private var playerManager: PlayerManager!
    private var syncManager: SyncManager!
    private var chatManager: ChatManager!
    private var accessToken: String?
    @Published var roomSID: String?
    private var subscriptions = Set<AnyCancellable>()
    @Published var meetingData: TwilioGeneratedTokenResponse?
    private let repository: TwilioDataRepository
    @Published var meetingId: String = ""
    
    @Published var isLoading = false
    let stateObservable = StateObservable.shared
    
    @Published var containHost: Bool = false
    
    init(
        repository: TwilioDataRepository = TwilioDataDefaultRepository()
    ) {
        self.repository = repository
    }
    
    func configure(
        roomManager: RoomManager,
        playerManager: PlayerManager,
        syncManager: SyncManager,
        chatManager: ChatManager
    ) {
        self.roomManager = roomManager
        self.playerManager = playerManager
        self.syncManager = syncManager
        self.chatManager = chatManager
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in
                self?.state = .connected
                self?.connectChat()
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
        
        syncManager.errorPublisher
            .sink { [weak self] error in self?.handleError(error) }
            .store(in: &subscriptions)
        
        playerManager.delegate = self
    }
    
    func connect(meetingId: String) {
        
        state = .connecting
        
        fetchAccessToken(meetingId: meetingId, fromChangeRole: false, role: "")
    }
    
    func disconnect() {
        roomManager.disconnect()
        playerManager.disconnect()
        syncManager.disconnect()
        chatManager.disconnect()
        player = nil
        state = .disconnected
    }
    
    /// Change role from viewer to speaker or speaker to viewer.
    ///
    /// - Note: The user that created the stream is the host. There is only one host and the host cannot change. When the host leaves the stream ends for all users.
    func changeRole(to role: String, meetingId: String) {
        guard role != "host" && stateObservable.twilioRole != "host" else {
            return
        }
        
        roomManager.disconnect()
        playerManager.disconnect()
        player = nil
        stateObservable.twilioRole = role
        state = .changingRole
        fetchAccessToken(meetingId: meetingId, fromChangeRole: true, role: role)
    }
    
    private func fetchAccessToken(meetingId: String, fromChangeRole: Bool, role: String) {
        let body = GenerateTokenTwilioType(type: role)
        repository.provideGenerateToken(on: meetingId, withBody: fromChangeRole, body: body)
            .sink { result in
                switch result {
                case .failure(let error):
                    self.handleError(error)
                    
                case .finished:
                    print("success")
                }
            } receiveValue: { response in
                self.meetingId = meetingId
                self.accessToken = response.token.orEmpty()
                self.roomSID = response.roomSid.orEmpty()
                self.isChatEnabled = response.chatEnabled ?? true
                self.stateObservable.twilioRole = response.joinAs.orEmpty()
                self.stateObservable.twilioAccessToken = response.token.orEmpty()
                self.stateObservable.twilioUserIdentity = response.userIdentity.orEmpty()
                
                let objectNames = StreamManager.ObjectNames(
                    speakersMap: (response.syncObjectNames?.speakersMap).orEmpty(),
                    viewersMap: (response.syncObjectNames?.viewersMap).orEmpty(),
                    raisedHandsMap: (response.syncObjectNames?.raisedHandsMap).orEmpty(),
                    userDocument: response.syncObjectNames?.userDocument,
                    roomDocument: response.syncObjectNames?.roomDocument
                )
                
                self.listenPath(object: objectNames, accessToken: response.token.orEmpty())
            }
            .store(in: &subscriptions)
        
    }
    
    //FIXME: -Please check this function
    private func listenPath(object: StreamManager.ObjectNames, accessToken: String) {
        listenViewerPath(object: object.viewersMap)
        listenRemoveViewerPath(object: object.viewersMap)
        listenRaisePath(object: object.raisedHandsMap)
        listenRemoveRaisePath(object: object.raisedHandsMap)
        listenSpeakerPath(object: object.speakersMap)
        listenRemoveSpeakerPath(object: object.speakersMap)
        
        if object.userDocument != nil {
            listenUserDocument(object: object.userDocument.orEmpty())
        }
        
        listenRoomDocument(object: object.roomDocument.orEmpty())
        self.connectRoomOrPlayer(accessToken: accessToken)
    }
    
    //FIXME: -Please check this function
    private func listenRoomDocument(object: String) {
        lazy var databasePathRoomDoc: DatabaseReference? = {
            let ref = Database.database(url: Configuration.shared.environment.firebaseRealtimeURL).reference(withPath: object)
            
            return ref
        }()
        
        guard let databasePathRoomDoc = databasePathRoomDoc else {
            return
        }
        
        databasePathRoomDoc
            .observe(.value) { snapshot in
                guard
                    let json = snapshot.value as? [String: Any]
                else {
                    return
                }
                
                if let qna = json["qnaSent"] as? Bool {
                    self.hasNewQuestion.send(qna)
                }
                
                if let micDisabled = json["micDisabled"] as? Bool {
                    self.speakerLockAudio.send(micDisabled)
                }
                
                if let spotlightUser = json["spotlightedIdentity"] as? String {
                    self.spotlightedIdentity.send(spotlightUser)
                } else {
                    self.spotlightedIdentity.send("")
                }
            }
    }
    
    //FIXME: -Please check this function
    private func listenUserDocument(object: String) {
        lazy var databasePathUserDoc: DatabaseReference? = {
            let ref = Database.database(url: Configuration.shared.environment.firebaseRealtimeURL).reference(withPath: object)
            
            return ref
        }()
        
        guard let databasePathUserDoc = databasePathUserDoc else {
            return
        }
        
        databasePathUserDoc
            .observe(.value) { snapshot in
                guard
                    let json = snapshot.value as? [String: Any]
                else {
                    return
                }
                
                guard let speakerInvite = json["speakerInvite"] as? Bool else { return }
                self.speakerInvitePublisher.send(speakerInvite)
            }
    }
    
    //FIXME: -Please check this function
    private func listenViewerPath(object: String) {
        lazy var databasePathViewer: DatabaseReference? = {
            let ref = Database.database(url: Configuration.shared.environment.firebaseRealtimeURL).reference(withPath: object)
            
            return ref
        }()
        
        guard let databasePathViewer = databasePathViewer else {
            return
        }
        
        databasePathViewer
            .observe(.value) { snapshot  in
                guard
                    let json = snapshot.value as? [String: Any]
                else {
                    return
                }
                
                for json in json {
                    if let data = snapshot.childSnapshot(forPath: json.key).value as? [String: Any],
                       let identity = data["identity"] as? String,
                       let name = data["name"] as? String
                    //                        let photo = data["profilePhoto"] as? String
                    {
                        
                        if !self.viewerArrayRealtime.contains(where: { item in
                            item.identity == identity
                        }) {
                            self.viewerArrayRealtime.append(ViewerRealtimeResponse(identity: identity, name: name, profilePhoto: "photo"))
                        }
                        
                    }
                }
                
                self.userUpdatePublisher.send(self.viewerArrayRealtime)
            }
        
    }
    
    private func listenRemoveViewerPath(object: String) {
        lazy var databasePathViewer: DatabaseReference? = {
            let ref = Database.database(url: Configuration.shared.environment.firebaseRealtimeURL).reference(withPath: object)
            
            return ref
        }()
        
        guard let databasePathViewer = databasePathViewer else {
            return
        }
        
        databasePathViewer
            .observe(.childRemoved) { snapshot  in
                guard
                    let json = snapshot.value as? [String: Any]
                else {
                    return
                }
                
                var viewer = [ViewerRealtimeResponse]()
                
                for json in json {
                    if let data = snapshot.childSnapshot(forPath: json.key).value as? [String: Any],
                       let identity = data["identity"] as? String,
                       let name = data["name"] as? String
                    //                       let photo = data["profilePhoto"] as? String
                    {
                        if !self.viewerArrayRealtime.contains(where: { item in
                            item.identity == identity
                        }) {
                            viewer.append(ViewerRealtimeResponse(identity: identity, name: name, profilePhoto: "photo"))
                        }
                        
                    }
                }
                
                self.viewerArrayRealtime = viewer
                self.userUpdatePublisher.send(self.viewerArrayRealtime)
            }
        
    }
    
    //FIXME: -Please check this function
    private func listenRaisePath(object: String) {
        lazy var databasePathRaised: DatabaseReference? = {
            let ref = Database.database(url: Configuration.shared.environment.firebaseRealtimeURL).reference(withPath: object)
            
            return ref
        }()
        
        guard let databasePathRaised = databasePathRaised else {
            return
        }
        
        databasePathRaised
            .observe(.value) { snapshot in
                guard
                    let json = snapshot.value as? [String: Any]
                else {
                    return
                }
                
                for json in json {
                    if let data = snapshot.childSnapshot(forPath: json.key).value as? [String: Any],
                       let identity = data["identity"] as? String
                    //                       let name = data["name"] as? String
                    //                       let photo = data["profilePhoto"] as? String
                    {
                        
                        self.raiseHandArrayRealtime.removeAll(where: { $0.identity == identity })
                        
                        if !self.raiseHandArrayRealtime.contains(where: { item in
                            item.identity == identity
                        }) {
                            
                            self.raiseHandArrayRealtime.append(ViewerRealtimeResponse(identity: identity, name: nil, profilePhoto: "photo"))
                            
                            self.haveNewRaiseHand.send(true)
                        }
                        
                    }
                }
                
                self.userRaiseHandUpdatePublisher.send(self.raiseHandArrayRealtime)
            }
    }
    
    private func listenRemoveRaisePath(object: String) {
        lazy var databasePathRaised: DatabaseReference? = {
            let ref = Database.database(url: Configuration.shared.environment.firebaseRealtimeURL).reference(withPath: object)
            
            return ref
        }()
        
        guard let databasePathRaised = databasePathRaised else {
            return
        }
        
        var raiseHandArray = [ViewerRealtimeResponse]()
        
        databasePathRaised
            .observe(.childRemoved) { snapshot in
                guard
                    let json = snapshot.value as? [String: Any]
                else {
                    return
                }
                
                for json in json {
                    if let data = snapshot.childSnapshot(forPath: json.key).value as? [String: Any],
                       let identity = data["identity"] as? String
                    //                       let name = data["name"] as? String
                    //                       let photo = data["profilePhoto"] as? String
                    {
                        
                        if !self.raiseHandArrayRealtime.contains(where: { item in
                            item.identity == identity
                        }) {
                            
                            raiseHandArray.append(ViewerRealtimeResponse(identity: identity, name: nil, profilePhoto: "photo"))
                        }
                        
                    }
                }
                
                self.raiseHandArrayRealtime = raiseHandArray
                self.userRaiseHandUpdatePublisher.send(self.raiseHandArrayRealtime)
            }
    }
    
    //FIXME: -Please check this function
    private func listenSpeakerPath(object: String) {
        lazy var databasePathSpeaker: DatabaseReference? = {
            let ref = Database.database(url: Configuration.shared.environment.firebaseRealtimeURL).reference(withPath: object)
            
            return ref
        }()
        
        guard let databasePathSpeaker = databasePathSpeaker else {
            return
        }
        
        databasePathSpeaker
            .observe(.value) { snapshot in
                guard
                    let json = snapshot.value as? [String: Any]
                else {
                    return
                }
                
                for json in json {
                    if let data = snapshot.childSnapshot(forPath: json.key).value as? [String: Any],
                       let coHost = data["coHost"] as? Bool,
                       let host = data["host"] as? Bool,
                       let identity = data["identity"] as? String,
                       let name = data["name"] as? String
                    //                       let photo = data["profilePhoto"] as? String
                    {
                        
                        if !self.speakerArrayRealtime.contains(where: { item in
                            item.identity == identity
                        }) {
                            self.speakerArrayRealtime.append(SpeakerRealtimeResponse(coHost: coHost, host: host, identity: identity, name: name, photoProfile: "photo"))
                        }
                        
                    }
                }
                
                self.containHost = self.speakerArrayRealtime.contains(where: {
                    $0.host ?? false
                })
                
                
                self.userSpeakerUpdatePublisher.send(self.speakerArrayRealtime)
            }
    }
    
    private func listenRemoveSpeakerPath(object: String) {
        lazy var databasePathSpeaker: DatabaseReference? = {
            let ref = Database.database(url: Configuration.shared.environment.firebaseRealtimeURL).reference(withPath: object)
            
            return ref
        }()
        
        guard let databasePathSpeaker = databasePathSpeaker else {
            return
        }
        
        var speakerArray = [SpeakerRealtimeResponse]()
        
        databasePathSpeaker
            .observe(.childRemoved) { snapshot in
                guard
                    let json = snapshot.value as? [String: Any]
                else {
                    return
                }
                
                for json in json {
                    if let data = snapshot.childSnapshot(forPath: json.key).value as? [String: Any],
                       let coHost = data["coHost"] as? Bool,
                       let host = data["host"] as? Bool,
                       let identity = data["identity"] as? String,
                       let name = data["name"] as? String
                    //                       let photo = data["profilePhoto"] as? String
                    {
                        
                        if !self.speakerArrayRealtime.contains(where: { item in
                            item.identity == identity
                        }) {
                            speakerArray.append(SpeakerRealtimeResponse(coHost: coHost, host: host, identity: identity, name: name, photoProfile: "photo"))
                        }
                        
                    }
                }
                
                self.containHost = speakerArray.contains(where: {
                    $0.host ?? false
                })

                
                self.speakerArrayRealtime = speakerArray
                self.userSpeakerUpdatePublisher.send(self.speakerArrayRealtime)
            }
    }
    
    private func connectRoomOrPlayer(accessToken: String) {
        switch stateObservable.twilioRole {
        case "host", "speaker":
            roomManager.connect(roomName: meetingId, accessToken: accessToken)
        case "viewer":
            playerManager.connect(accessToken: accessToken)
        default:
            playerManager.connect(accessToken: accessToken)
        }
    }
    
    private func connectChat() {
        guard isChatEnabled, !chatManager.isConnected, let accessToken = accessToken, let roomSID = roomSID else {
            return
        }
        
        chatManager.connect(accessToken: accessToken, conversationName: roomSID)
    }
    
    private func handleError(_ error: Error) {
        disconnect()
        errorPublisher.send(error)
    }
}

extension StreamManager: PlayerManagerDelegate {
    func playerManagerDidConnect(_ playerManager: PlayerManager) {
        player = playerManager.player
        state = .connected
        
        let body = SyncTwilioGeneralBody(userIdentity: stateObservable.twilioUserIdentity)
        repository.provideSyncViewerConnectedToPlayer(on: meetingId, target: body)
            .sink { result in
                switch result {
                case .finished:
                    break
                case let .failure(error):
                    self.handleError(error)
                }
            } receiveValue: { _ in
                
            }
            .store(in: &subscriptions)
        
        connectChat() /// Chat is not essential so connect it separately
    }
    
    func playerManager(_ playerManager: PlayerManager, didDisconnectWithError error: Error) {
        handleError(error)
    }
}

