//
//  StreamManager.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import Combine
import TwilioLivePlayer
import Foundation

final class StreamManager: ObservableObject {
	enum State {
		case disconnected
		case connecting
		case connected
		case changingRole
	}
	
	let errorPublisher = PassthroughSubject<Error, Never>()
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
				self?.connectChat() /// Chat is not essential so connect it separately
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
				
				let objectNames = SyncManager.ObjectNames(
					speakersMap: (response.syncObjectNames?.speakersMap).orEmpty(),
					viewersMap: (response.syncObjectNames?.viewersMap).orEmpty(),
					raisedHandsMap: (response.syncObjectNames?.raisedHandsMap).orEmpty(),
					userDocument: response.syncObjectNames?.userDocument,
					roomDocument: response.syncObjectNames?.roomDocument
				)
				
				self.connectSync(accessToken: response.token.orEmpty(), objectNames: objectNames)
			}
			.store(in: &subscriptions)
		
	}
	
	private func connectSync(accessToken: String, objectNames: SyncManager.ObjectNames) {
		
		var newObjectNames: SyncManager.ObjectNames
		
		switch stateObservable.twilioRole {
		case "host":
			newObjectNames = SyncManager.ObjectNames(speakersMap: objectNames.speakersMap, viewersMap: objectNames.viewersMap, raisedHandsMap: objectNames.raisedHandsMap, userDocument: nil, roomDocument: objectNames.roomDocument)
		case "speaker":
			newObjectNames = SyncManager.ObjectNames(speakersMap: objectNames.speakersMap, viewersMap: objectNames.viewersMap, raisedHandsMap: objectNames.raisedHandsMap, userDocument: objectNames.userDocument, roomDocument: objectNames.roomDocument)
		default:
			newObjectNames = SyncManager.ObjectNames(speakersMap: objectNames.speakersMap, viewersMap: objectNames.viewersMap, raisedHandsMap: objectNames.raisedHandsMap, userDocument: objectNames.userDocument, roomDocument: nil)
		}
		
		syncManager.connect(token: accessToken, objectNames: newObjectNames) { [weak self] error in
			if let error = error {
				self?.handleError(error)
				return
			}
			
			print("Connected")
			
			self?.connectRoomOrPlayer(accessToken: accessToken)
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
