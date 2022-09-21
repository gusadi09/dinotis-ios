//
//  SyncRoomDocument.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/08/22.
//

import Combine
import TwilioSyncClient

class SyncRoomDocument: NSObject, SyncObjectConnecting {
	let speakerLockAudio = PassthroughSubject<Bool, Never>()
	let spotlightedIdentity = PassthroughSubject<String, Never>()
	let hasNewQuestion = PassthroughSubject<Bool, Never>()
	var uniqueName: String!
	var errorHandler: ((Error) -> Void)?
	private var document: TWSDocument?
	
	func connect(client: TwilioSyncClient, completion: @escaping (Error?) -> Void) {
		guard let options = TWSOpenOptions.open(withSidOrUniqueName: uniqueName) else { return }
		
		client.openDocument(with: options, delegate: self) { [weak self] result, document in
			guard let document = document else {
				completion(result.error!)
				return
			}
			
			self?.document = document
			completion(nil)
		}
	}
	
	func disconnect() {
		document = nil
	}
}

extension SyncRoomDocument: TWSDocumentDelegate {
	func onDocumentOpened(_ document: TWSDocument) {
		if let isAudioLock = document.data["mic_disabled"] as? Bool {
			speakerLockAudio.send(isAudioLock)
		} else if let newQuestion = document.data["qna_sent"] as? Bool {
			hasNewQuestion.send(newQuestion)
		}
		
		spotlightedIdentity.send((document.data["spotlighted_identity"] as? String).orEmpty())
	}
	
	func onDocument(
		_ document: TWSDocument,
		updated data: [String : Any],
		previousData: [String : Any],
		eventContext: TWSEventContext
	) {
		
		if let isAudioLock = data["mic_disabled"] as? Bool {
			speakerLockAudio.send(isAudioLock)
		} else if let newQuestion = data["qna_sent"] as? Bool {
			hasNewQuestion.send(newQuestion)
		}
		
		spotlightedIdentity.send((data["spotlighted_identity"] as? String).orEmpty())
	}
	
	func onDocument(_ document: TWSDocument, errorOccurred error: TWSError) {
		disconnect()
		errorHandler?(error)
	}
}
