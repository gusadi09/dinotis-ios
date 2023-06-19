//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine

class ParticipantsViewModel: ObservableObject {
	
	private let repository: TwilioDataRepository
	
	@Published var speakers: [SpeakerRealtimeResponse] = []
	@Published var viewersWithRaisedHand: [ViewerRealtimeResponse] = []
	@Published var viewersWithoutRaisedHand: [ViewerRealtimeResponse] = []
	@Published var viewerCount = 0
	@Published var haveNewRaisedHand = false
	@Published var showError = false
	@Published var showSpeakerInviteSent = false
	@Published var invitedSpeakerData: InvitedResponse?
	private(set) var error: Error? {
		didSet {
			showError = error != nil
		}
	}
	private var newRaisedHands: [SyncUsersMap.User] = [] {
		didSet {
			haveNewRaisedHand = !newRaisedHands.isEmpty
		}
	}
	private var streamManager: StreamManager?
	private var roomManager: RoomManager?
	private var speakersMap: SyncUsersMap?
	private var viewersMap: SyncUsersMap?
	private var raisedHandsMap: SyncUsersMap?
	private var subscriptions = Set<AnyCancellable>()
	
	init(
		repository: TwilioDataRepository = TwilioDataDefaultRepository()
	) {
		self.repository = repository
	}
	
	func configure(
		streamManager: StreamManager,
		roomManager: RoomManager,
		speakersMap: SyncUsersMap,
		viewersMap: SyncUsersMap,
		raisedHandsMap: SyncUsersMap
	) {
		self.streamManager = streamManager
		self.roomManager = roomManager
		self.speakersMap = speakersMap
		self.viewersMap = viewersMap
		self.raisedHandsMap = raisedHandsMap
		
		streamManager.$state
			.sink { [weak self] state in self?.handleStreamStateChange(state) }
			.store(in: &subscriptions)

		//FIXME: - Change to firebase
		streamManager.userSpeakerUpdatePublisher
			.sink { [weak self] arraySpeaker in
				self?.speakers = arraySpeaker
			}
			.store(in: &subscriptions)

		//FIXME: - Change to firebase
		streamManager.userUpdatePublisher
			.sink { [weak self] viewerArray in
				self?.viewersWithoutRaisedHand = viewerArray
			}
			.store(in: &subscriptions)

		//FIXME: - Change to firebase
		streamManager.userRaiseHandUpdatePublisher
			.sink { [weak self] raiseHandArray in
				self?.viewersWithRaisedHand = raiseHandArray
			}
			.store(in: &subscriptions)

		streamManager.haveNewRaiseHand
			.sink { [weak self] value in
				self?.haveNewRaisedHand = value
			}
			.store(in: &subscriptions)
	}
	
	func sendSpeakerInvite(meetingId: String, userIdentity: String) {
		
		let target = SyncTwilioGeneralBody(userIdentity: userIdentity)
		
		repository.provideSyncSendSpeakerInvite(on: meetingId, target: target)
			.sink { [weak self] result in
				switch result {
				case .failure(let error):
					self?.error = error
				case .finished:
					self?.showSpeakerInviteSent = true
				}
			} receiveValue: { [self] value in
				invitedSpeakerData = value
			}
			.store(in: &subscriptions)
	}
	
	private func handleStreamStateChange(_ state: StreamManager.State) {
		switch state {
		case .disconnected:
			speakers = []
			viewersWithRaisedHand = []
			viewersWithoutRaisedHand = []
			newRaisedHands = []
			viewerCount = 0
			error = nil
		case .connected:
			guard speakers.count == .zero else {
				return // The user just changed role so don't load everything again
			}
			
		case .connecting, .changingRole:
			break
		}
	}
	
	private func removeSpeaker(user: SyncUsersMap.User) {
		speakers.removeAll { $0.identity == user.identity }
	}
	
	private func removeViewer(user: SyncUsersMap.User) {
		viewersWithoutRaisedHand.removeAll { $0.identity == user.identity }
		updateViewerCount()
	}
	
	private func addRaisedHand(user: SyncUsersMap.User) {
		updateViewerCount()
	}
	
	private func removeRaisedHand(user: SyncUsersMap.User) {
		viewersWithRaisedHand.removeAll { $0.identity == user.identity }
		newRaisedHands.removeAll { $0.identity == user.identity }
		
		updateViewerCount()
	}
	
	func updateViewerCount() -> Int {
		viewersWithoutRaisedHand.unique().count
	}
}
