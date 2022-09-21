//
//  ScheduleDetailViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/02/22.
//

import Foundation
import Combine
import SwiftUI

final class ScheduleDetailViewModel: ObservableObject {

	private let meetingsRepo: MeetingsRepository
	private let userRepo: UsersRepository
	private let authRepo: AuthenticationRepository
	private let stateObservable = StateObservable.shared
	private var cancellables = Set<AnyCancellable>()

	@Published var goToEdit = false

	@Published var isRestricted = false

	@Published var totalPrice = 0

	@Published var isDeleteShow = false

	@Published var isEndShow = false

	@Published var startPresented = false

	@Published var meetingForm = MeetingForm(id: String.random(), title: "", description: "", price: 10000, startAt: "", endAt: "", isPrivate: true, slots: 0)
	
	@Published var randomId = UInt.random(in: .init(1...99999999))

	@Published var conteOffset = CGFloat.zero

	@Published var tabColor = Color.clear

	@Published var presentDelete = false

	@Published var bookingId: String

	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: HMError?
	@Published var HTMLContent = ""

	@Published var isRefreshFailed = false

	@Published var isShowingRules = false
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	@Published var route: HomeRouting?

	@Published var isEndSuccess = false
	@Published var isDeleteSuccess = false
	
	init(
		meetingsRepo: MeetingsRepository = MeetingsDefaultRepository(),
		userRepo: UsersRepository = UsersDefaultRepository(),
		authRepo: AuthenticationRepository = AuthenticationDefaultRepository(),
		bookingId: String,
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void)
	) {
		self.meetingsRepo = meetingsRepo
		self.userRepo = userRepo
		self.authRepo = authRepo
		self.bookingId = bookingId
		self.backToRoot = backToRoot
		self.backToHome = backToHome
	}

	func onAppearView() {
		self.getMeetingRules()
	}

	func onStartFetch() {
		DispatchQueue.main.async { [weak self] in
			self?.error = nil
			self?.success = false
			self?.isError = false
			self?.isLoading = true
			self?.isEndSuccess = false
			self?.isDeleteSuccess = false
		}
	}

	func endMeeting() {
		onStartFetch()

		meetingsRepo.providePatchEndMeeting(by: bookingId)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.endMeeting()
							})
						} else {
							self?.isError = true
							self?.isLoading = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isEndSuccess = true
						self?.isLoading = false
					}
				}
			} receiveValue: { _ in

			}
			.store(in: &cancellables)

	}

	func deleteMeeting() {
		onStartFetch()

		meetingsRepo.provideDeleteMeeting(by: bookingId)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.deleteMeeting()
							})
						} else {
							self?.isError = true
							self?.isLoading = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isDeleteSuccess = true
						self?.isLoading = false
					}
				}
			} receiveValue: { _ in
				
			}
			.store(in: &cancellables)

	}

	func getMeetingRules() {
		onStartFetch()

		meetingsRepo.provideGetMeetingsRules()
			.sink(
				receiveCompletion: { result in
					switch result {
					case .failure(let error):
						DispatchQueue.main.async {[weak self] in
							if error.statusCode.orZero() == 401 {
								self?.refreshToken(onComplete: self?.getMeetingRules ?? {})
							} else {
								self?.isError = true
								self?.isLoading = false

								self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
							}
						}

					case .finished:
						DispatchQueue.main.async { [weak self] in
							self?.success = true
							self?.isLoading = false
						}
					}
				}, receiveValue: { value in
					DispatchQueue.main.async { [weak self] in
						self?.HTMLContent = value.content.orEmpty()
					}
				}
			)
			.store(in: &cancellables)

	}

	func onStartRefresh() {
		DispatchQueue.main.async { [weak self] in
			self?.isRefreshFailed = false
			self?.isLoading = true
			self?.success = false
			self?.error = nil
		}

	}

	func refreshToken(onComplete: @escaping (() -> Void)) {
		onStartRefresh()

		let refreshToken = authRepo.loadFromKeychain(forKey: KeychainKey.refreshToken)

		authRepo
			.refreshToken(with: refreshToken)
			.sink { result in
				switch result {
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						self?.isLoading = false
						onComplete()
					}

				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						self?.isRefreshFailed = true
						self?.isLoading = false
						self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
					}
				}
			} receiveValue: { value in
				self.stateObservable.refreshToken = value.refreshToken
				self.stateObservable.accessToken = value.accessToken
			}
			.store(in: &cancellables)
	}

	func convertToUserMeet(meet: DetailMeeting) -> UserMeeting {
		let meet = UserMeeting(
			id: meet.id,
			title: meet.title.orEmpty(),
			meetingDescription: meet.description.orEmpty(),
			price: meet.price.orEmpty(),
			startAt: meet.startAt.orEmpty(),
			endAt: meet.endAt.orEmpty(),
			isPrivate: meet.isPrivate,
			isLiveStreaming: meet.isLiveStreaming,
			slots: meet.slots,
			userID: meet.userID,
			startedAt: meet.startedAt,
			endedAt: meet.endedAt,
			createdAt: meet.createdAt,
			updatedAt: meet.updatedAt,
			deletedAt: meet.deletedAt,
			bookings: [],
			user: nil
		)

		return meet
	}
	
	func routeToVideoCall(meeting: UserMeeting) {
		let viewModel = PrivateVideoCallViewModel(meeting: meeting, backToRoot: self.backToRoot, backToHome: self.backToHome)
		
		DispatchQueue.main.async {[weak self] in
			self?.route = .videoCall(viewModel: viewModel)
		}
	}
    
    func routeToTwilioLiveStream(meeting: UserMeeting) {
        let viewModel = TwilioLiveStreamViewModel(
            backToRoot: self.backToRoot,
            backToHome: self.backToHome,
            meeting: meeting
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .twilioLiveStream(viewModel: viewModel)
        }
    }
}
