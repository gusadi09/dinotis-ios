//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioLivePlayer
import SwiftUI

class StreamViewModel: ObservableObject {
	enum AlertIdentifier: String, Identifiable {
		case error
		case receivedSpeakerInvite
		case speakerMovedToViewersByHost
		case streamEndedByHost
		case streamWillEndIfHostLeaves
		case viewerConnected
		case mutedByHost
		case unlockedMuteByHost
        case removeAllParticipant
		
		var id: String { rawValue }
	}
	
	@Published var spotlightUser = ""
	@Published var hasNewQuestion = false
	@Published var isHandRaised = false {
		didSet {
			guard streamManager.state == .connected else {
				return
			}
			
			repository.provideSyncRaiseHand(
				on: streamManager.meetingId,
				target: SyncRaiseHandBody(
					userIdentity: state.twilioUserIdentity,
					raised: isHandRaised
				)
			)
			.sink { result in
				switch result {
				case .failure(let error):
					self.handleError(error, meetingId: self.streamManager.meetingId)
				case .finished:
					break
				}
			} receiveValue: { response in
				print(response)
			}
			.store(in: &subscriptions)
			
		}
	}
	@Published var alertIdentifier: AlertIdentifier?
	@Published var isAudioLocked = false
	private(set) var error: Error?
	private var haveShownViewerConnectedAlert = false
	private var streamManager: StreamManager!
	private var userDocument: SyncUserDocument!
	private var roomDocument: SyncRoomDocument!
	private var speakerSettingsManager: SpeakerSettingsManager!
	private var subscriptions = Set<AnyCancellable>()
	private let repository: TwilioDataRepository
	let state = StateObservable.shared
	
	init(repository: TwilioDataRepository = TwilioDataDefaultRepository()) {
		self.repository = repository
	}
	
	func configure(
		streamManager: StreamManager,
		speakerSettingsManager: SpeakerSettingsManager,
		userDocument: SyncUserDocument,
		meetingId: String,
		roomDocument: SyncRoomDocument
	) {
		self.streamManager = streamManager
		self.speakerSettingsManager = speakerSettingsManager
		self.userDocument = userDocument
		self.roomDocument = roomDocument
		
		speakerSettingsManager.$isMuted.sink { [weak self] state in
			switch state {
			case true:
				self?.alertIdentifier = .mutedByHost
			default:
				break;
			}
		}
		.store(in: &subscriptions)
		
		streamManager.$state
			.sink { [weak self] state in
				guard let self = self, streamManager.config != nil else {
					return
				}
				
				switch state {
				case .connecting, .changingRole:
					switch streamManager.stateObservable.twilioRole {
					case "host", "speaker":
						self.speakerSettingsManager.isMicOn = true
						self.speakerSettingsManager.isCameraOn = true
					case "viewer":
						self.speakerSettingsManager.isMicOn = false
						self.speakerSettingsManager.isCameraOn = false
						self.isHandRaised = false
						
					default:
						self.speakerSettingsManager.isMicOn = false
						self.speakerSettingsManager.isCameraOn = false
						self.isHandRaised = false
					}
				case .disconnected:
					self.speakerSettingsManager.isMicOn = false
					self.speakerSettingsManager.isCameraOn = false
				case .connected:
					switch streamManager.stateObservable.twilioRole {
					case "viewer":
						if !self.haveShownViewerConnectedAlert {
							self.haveShownViewerConnectedAlert = true
							self.alertIdentifier = .viewerConnected
						}
					case "host", "speaker":
						break
						
					default:
						break
					}
				}
			}
			.store(in: &subscriptions)
		
		streamManager.errorPublisher
			.sink { [weak self] error in self?.handleError(error, meetingId: meetingId) }
			.store(in: &subscriptions)
		
		userDocument.speakerInvitePublisher
			.sink { [weak self] in
				self?.alertIdentifier = .receivedSpeakerInvite
			}
			.store(in: &subscriptions)
		
		roomDocument.speakerLockAudio
			.sink { [weak self] value in
				self?.isAudioLocked = value
				
				if !value && StateObservable.shared.twilioRole != "host" {
					self?.alertIdentifier = .unlockedMuteByHost
				}
			}
			.store(in: &subscriptions)
		
		roomDocument.hasNewQuestion
			.sink { [weak self] value in
				self?.hasNewQuestion = value
			}
			.store(in: &subscriptions)

		roomDocument.spotlightedIdentity
			.sink { value in
				print("identity:", value)
				self.spotlightUser = value
			}
			.store(in: &subscriptions)
	}
	
	private func handleError(_ error: Error, meetingId: String) {
		streamManager.disconnect()
		
		if error.isStreamEndedByHostError {
			alertIdentifier = .streamEndedByHost
		} else if error.isSpeakerMovedToViewersByHostError {
			alertIdentifier = .speakerMovedToViewersByHost
			streamManager.changeRole(to: "viewer", meetingId: meetingId)
		} else {
			self.error = error
			alertIdentifier = .error
		}
	}
}

private extension Error {
	var isSpeakerMovedToViewersByHostError: Bool {
		if case .speakerMovedToViewersByHost = self as? LiveVideoError {
			return true
		}
		
		return false
	}
	
	var isStreamEndedByHostError: Bool {
		if case .streamEndedByHost = self as? LiveVideoError {
			return true
		}
		
		return false
	}
}
