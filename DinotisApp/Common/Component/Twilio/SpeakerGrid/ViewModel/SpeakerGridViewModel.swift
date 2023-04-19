//
//  SpeakerGridViewModel.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import TwilioVideo
import Combine
import DinotisData

/// Subscribes to room and participant state changes to provide speaker state for the UI to display in a grid
class SpeakerGridViewModel: ObservableObject {

	struct Page: Hashable {
		let identifier: Int
		var speakerPage: [SpeakerVideoViewModel]

		static func == (lhs: Page, rhs: Page) -> Bool {
			lhs.identifier == rhs.identifier
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(identifier)
		}
	}

	@Published var isEnd = false
	@Published var onscreenSpeakers: [SpeakerVideoViewModel] = []
	@Published var isUpdated = false

	@Published var pages: [Page] = []
	private let maxParticipantsPerPage = 4
	private var roomManager: RoomManager!
	private var speakersMap: SyncUsersMap!
	@Published var speakerVideoViewModelFactory: SpeakerVideoViewModelFactory!
	private var subscriptions = Set<AnyCancellable>()
	
	func configure(
		roomManager: RoomManager,
		speakersMap: SyncUsersMap,
		speakerVideoViewModelFactory: SpeakerVideoViewModelFactory
	) {
		self.roomManager = roomManager
		self.speakersMap = speakersMap
		self.speakerVideoViewModelFactory = speakerVideoViewModelFactory
		
		roomManager.roomConnectPublisher
			.sink { [weak self] in
				guard let self = self else { return }

				self.addParticipant(self.speakerVideoViewModelFactory.makeSpeaker(participant: self.roomManager.localParticipant))

				self.onscreenSpeakers.append(self.speakerVideoViewModelFactory.makeSpeaker(participant: self.roomManager.localParticipant))
				
				self.roomManager.remoteParticipants
					.map { self.speakerVideoViewModelFactory.makeSpeaker(participant: $0) }
					.forEach {
						self.addParticipant($0)
						self.onscreenSpeakers.append($0)
					}
				
				self.isUpdated = true
				
			}
			.store(in: &subscriptions)
		
		roomManager.roomDisconnectPublisher
			.sink { [weak self] _ in
				self?.onscreenSpeakers.removeAll()
				self?.pages.removeAll(where: \.speakerPage.isEmpty)
			}
			.store(in: &subscriptions)
		
		roomManager.localParticipant.changePublisher
			.sink { [weak self] participant in
				
				guard let self = self, !self.pages.isEmpty else { return }

				self.pages[0].speakerPage[0] = self.speakerVideoViewModelFactory.makeSpeaker(participant: participant)
				self.updateSpeaker(self.speakerVideoViewModelFactory.makeSpeaker(participant: participant))
				
			}
			.store(in: &subscriptions)
		
		roomManager.remoteParticipantConnectPublisher
			.sink { [weak self] participant in
				guard let self = self else { return }

				self.onscreenSpeakers.append(self.speakerVideoViewModelFactory.makeSpeaker(participant: participant))
				self.addParticipant(self.speakerVideoViewModelFactory.makeSpeaker(participant: participant))
			}
			.store(in: &subscriptions)
		
		roomManager.remoteParticipantDisconnectPublisher
			.sink {
				[weak self] participant in
				self?.removeParticipant(identity: participant.identity)
				self?.removeSpeaker(with: participant.identity)
			}
			.store(in: &subscriptions)
		
		roomManager.remoteParticipantChangePublisher
			.sink { [weak self] participant in
				guard let self = self else { return }
				
				self.isUpdated = true
				self.updateSpeaker(self.speakerVideoViewModelFactory.makeSpeaker(participant: participant))
				self.updateParticipant(self.speakerVideoViewModelFactory.makeSpeaker(participant: participant))
			}
			.store(in: &subscriptions)
	}

	func updateObservable(_ identity: String) {
		guard let indexPath = pages.indexPathOfParticipant(identity: identity) else {
			return
		}

		if StateObservable.shared.spotlightedIdentity == StateObservable.shared.twilioUserIdentity {
			self.pages[0].speakerPage[0] = self.pages[indexPath.section].speakerPage[indexPath.item]
			self.updateParticipant(self.pages[indexPath.section].speakerPage[indexPath.item])
		}

	}

	func addParticipant(_ participant: SpeakerVideoViewModel) {
		pages.appendParticipant(participant, maxParticipantsPerPage: maxParticipantsPerPage)
	}

	func removeParticipant(identity: String) {
		guard let indexPath = pages.indexPathOfParticipant(identity: identity) else {
			return
		}

		if indexPath.section == 0 && pages.count > 1 {
			/// Special case to minimize ordering changes on the first page
			pages.removeParticipant(at: indexPath, shouldShift: false)
			pages.insertParticipant(
				pages[1].speakerPage[0],
				at: indexPath,
				maxParticipantsPerPage: maxParticipantsPerPage,
				shouldShift: false
			)
			pages.removeParticipant(at: IndexPath(item: 0, section: 1))
		} else {
			pages.removeParticipant(at: indexPath)
		}
	}

	func updateParticipant(_ participant: SpeakerVideoViewModel) {
		guard let indexPath = pages.indexPathOfParticipant(identity: participant.identity) else {
			return
		}

		if indexPath.section == 0 {
			pages[indexPath.section].speakerPage[indexPath.item] = participant
		} else {
			pages[indexPath.section].speakerPage[indexPath.item] = participant

			if participant.isDominantSpeaker {
				/// Always keep the most recent dominant speakers on the first page
				let oldestDominantSpeaker = pages[0].speakerPage[1...] // Skip local user at 0
					.sorted { $0.dominantSpeakerStartTime < $1.dominantSpeakerStartTime }
					.first!
				let oldestDominantSpeakerIndexPath = IndexPath(
					item: pages[0].speakerPage.firstIndex(of: oldestDominantSpeaker)!,
					section: 0
				)
				pages.removeParticipant(at: oldestDominantSpeakerIndexPath, shouldShift: false)
				pages.insertParticipant(
					participant,
					at: oldestDominantSpeakerIndexPath,
					maxParticipantsPerPage: maxParticipantsPerPage,
					shouldShift: false
				)
				pages.removeParticipant(at: indexPath)
				pages.insertParticipant(
					oldestDominantSpeaker,
					at: IndexPath(item: 0, section: 1),
					maxParticipantsPerPage: maxParticipantsPerPage
				)
			}
		}
	}

	func removeSpeaker(with identity: String) {
		if let index = onscreenSpeakers.firstIndex(where: { $0.identity == identity }) {
			onscreenSpeakers.remove(at: index)
		}
	}

	func updateSpeaker(_ speaker: SpeakerVideoViewModel) {
		if let index = onscreenSpeakers.firstIndex(of: speaker) {
			onscreenSpeakers[index] = speaker

			onscreenSpeakers = onscreenSpeakers.sorted(by: {
				$0.dominantSpeakerStartTime > $1.dominantSpeakerStartTime
			})
		}
	}

}

extension Array where Element == SpeakerGridViewModel.Page {
	func indexPathOfParticipant(identity: String) -> IndexPath? {
		for (section, page) in enumerated() {
			for (item, participant) in page.speakerPage.enumerated() {
				if participant.identity == identity {
					return IndexPath(item: item, section: section)
				}
			}
		}

		return nil
	}

	mutating func appendParticipant(_ participant: SpeakerVideoViewModel, maxParticipantsPerPage: Int) {
		if !isEmpty && last!.speakerPage.count < maxParticipantsPerPage {
			self[endIndex - 1].speakerPage.append(participant)
		} else {
			let newPage = SpeakerGridViewModel.Page(identifier: endIndex, speakerPage: [participant])
			append(newPage)
		}
	}

	mutating func insertParticipant(
		_ participant: SpeakerVideoViewModel,
		at indexPath: IndexPath,
		maxParticipantsPerPage: Int,
		shouldShift: Bool = true
	) {
		if indexPath.section == endIndex {
			let newPage = SpeakerGridViewModel.Page(identifier: indexPath.section, speakerPage: [participant])
			append(newPage)
		} else {
			self[indexPath.section].speakerPage.insert(participant, at: indexPath.item)

			if shouldShift {
				shiftRight(pageIndex: indexPath.section, maxParticipantsPerPage: maxParticipantsPerPage)
			}
		}
	}

	mutating func removeParticipant(at indexPath: IndexPath, shouldShift: Bool = true) {
		self[indexPath.section].speakerPage.remove(at: indexPath.item)

		if shouldShift {
			shiftLeft(pageIndex: indexPath.section)
		}
	}

	private mutating func shiftLeft(pageIndex: Int) {
		if pageIndex < endIndex - 1 {
			self[pageIndex].speakerPage.append(self[pageIndex + 1].speakerPage.removeFirst())
			shiftLeft(pageIndex: pageIndex + 1)
		} else if self[pageIndex].speakerPage.isEmpty {
			// If the last page is empty remove it
			remove(at: pageIndex)
		}
	}

	private mutating func shiftRight(pageIndex: Int, maxParticipantsPerPage: Int) {
		guard self[pageIndex].speakerPage.count > maxParticipantsPerPage else {
			return
		}

		if pageIndex == endIndex - 1 {
			let newPage = SpeakerGridViewModel.Page(
				identifier: pageIndex + 1,
				speakerPage: [self[pageIndex].speakerPage.removeLast()]
			)
			append(newPage)
		} else {
			self[pageIndex + 1].speakerPage.insert(self[pageIndex].speakerPage.removeLast(), at: 0)
			shiftRight(pageIndex: pageIndex + 1, maxParticipantsPerPage: maxParticipantsPerPage)
		}
	}
}
