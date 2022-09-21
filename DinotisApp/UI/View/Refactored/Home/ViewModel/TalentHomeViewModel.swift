//
//  HomeViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import SwiftUI
import Combine
import OneSignal

final class TalentHomeViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	
	private var cancellables = Set<AnyCancellable>()
	
	private var stateObservable = StateObservable.shared
	private let userRepository: UsersRepository
	private let authRepository: AuthenticationRepository
	private let homeRepository: HomeRepository
	private let meetRepository: MeetingsRepository

	@Published var filterSelection = "Jadwal Yang Tersedia"
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
	@Published var filterOption = [OptionQuery]()
	@Published var meetingData = [Meeting]()
	@Published var meetingParam = MeetingsParams(take: 15, skip: 0, isStarted: "", isEnded: "false", isAvailable: "true")
	
	@Published var photoProfile: String?
	@Published var isShowDelete = false
	@Published var isSuccessDelete = false
	@Published var meetingForm = MeetingForm(id: String.random(), title: "", description: "", price: 10000, startAt: "", endAt: "", isPrivate: true, slots: 0)
	@Published var isErrorAdditionalShow = false
	@Published var goToEdit = false
	@Published var talentMeetingError = false

	@Published var meetingId = ""
	@Published var currentBalances: Int = 0
	
	@Published var isRefreshFailed = false
	
	@Published var nameOfUser: String?
	@Published var userData: Users?
	
	@Published var showingPasswordAlert = false
	
	@Published var route: HomeRouting?
	
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false
	
	@Published var contentOffset = CGFloat.zero
	@Published var isLoading = false

	@Published var announceData = [AnnouncementData]()
	@Published var announceIndex = 0
	
	init(
		backToRoot: @escaping (() -> Void),
		userRepository: UsersRepository = UsersDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		homeRepository: HomeRepository = HomeDefaultRepository(),
		meetRepository: MeetingsRepository = MeetingsDefaultRepository()
	) {
		self.backToRoot = backToRoot
		self.userRepository = userRepository
		self.authRepository = authRepository
		self.homeRepository = homeRepository
		self.meetRepository = meetRepository
	}
	
	func routeToProfile() {
		let viewModel = ProfileViewModel(backToRoot: backToRoot, backToHome: { self.route = nil })
		
		DispatchQueue.main.async { [weak self] in
			if self?.stateObservable.userType == 2 {
				self?.route = .talentProfile(viewModel: viewModel)
			} else {
				self?.route = .userProfile(viewModel: viewModel)
			}
		}
	}
	
	func routeToTalentFormSchedule() {
		let viewModel = ScheculedFormViewModel(backToRoot: self.backToRoot, backToHome: {self.route = nil})
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .talentFormSchedule(viewModel: viewModel)
		}
	}
	
	func routeToTalentDetailSchedule() {
		let viewModel = ScheduleDetailViewModel(bookingId: meetingId, backToRoot: self.backToRoot, backToHome: {self.route = nil})
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .talentScheduleDetail(viewModel: viewModel)
		}
	}
	
	func routeToWallet() {
		let viewModel = TalentWalletViewModel(backToRoot: self.backToRoot, backToHome: {self.route = nil})
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .talentWallet(viewModel: viewModel)
		}
	}
	
	func routeToReset() {
		let viewModel = LoginPasswordResetViewModel(isFromHome: true, backToRoot: self.backToRoot, backToLogin: {})
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .loginResetPassword(viewModel: viewModel)
		}
	}

	func routeBack() {
		self.backToRoot()
		stateObservable.userType = 0
		stateObservable.isVerified = ""
		stateObservable.refreshToken = ""
		stateObservable.accessToken = ""
		stateObservable.isAnnounceShow = false
		OneSignal.setExternalUserId("")
	}

	func onAppearView() {
		self.getUsers()
		self.getAnnouncement()
		self.getCurrentBalance()
		self.getTalentMeeting()
	}
	
	func onStartedFetch() {
		DispatchQueue.main.async {[weak self] in
			self?.isError = false
			self?.isLoading = true
			self?.error = nil
			self?.success = false
		}
	}
	
	func onStartRefresh() {
		self.isRefreshFailed = false
		self.isLoading = true
		self.success = false
		self.error = nil
	}

	func refreshList() async {
		withAnimation(.spring()) {
			getTalentMeeting()
			getUsers()
		}
	}

	func use(for scrollView: UIScrollView, onValueChanged: @escaping ((UIRefreshControl) -> Void)) {
		DispatchQueue.main.async {
			let refreshControl = UIRefreshControl()
			refreshControl.addTarget(
				self,
				action: #selector(self.onValueChangedAction),
				for: .valueChanged
			)
			scrollView.refreshControl = refreshControl
			self.onValueChanged = onValueChanged
		}

	}

	@objc private func onValueChangedAction(sender: UIRefreshControl) {
		Task.init {
			self.onValueChanged?(sender)
		}
	}

	func getTalentMeeting() {
		onStartedFetch()

		meetRepository.provideGetTalentMeeting(params: meetingParam)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.getTalentMeeting()
							})
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
			} receiveValue: { value in
				self.filterOption = value.filters?.options ?? []
				self.meetingData += value.data

			}
			.store(in: &cancellables)

	}

	func onStartedDeleteMeeting() {
		DispatchQueue.main.async {[weak self] in
			self?.isErrorAdditionalShow = false
			self?.isLoading = true
			self?.error = nil
			self?.isSuccessDelete = false
		}
	}

	func deleteMeeting() {
		onStartedDeleteMeeting()

		meetRepository.provideDeleteMeeting(by: meetingId)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.deleteMeeting()
							})
						} else {
							self?.isErrorAdditionalShow = true
							self?.isLoading = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isSuccessDelete = true
						self?.isLoading = false
					}
				}
			} receiveValue: { _ in
				self.meetingData = []
				self.meetingParam.skip = 0
				self.meetingParam.take = 15
				self.getTalentMeeting()
			}
			.store(in: &cancellables)

	}

	func getCurrentBalance() {
		onStartedFetch()

		userRepository.provideUserCurrentBalance()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getCurrentBalance ?? {})
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
			} receiveValue: { value in
				self.currentBalances = value.current.orZero()
			}
			.store(in: &cancellables)

	}

	func getAnnouncement() {
		onStartedFetch()

		homeRepository
			.provideGetAnnouncementBanner()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getAnnouncement ?? {})
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
			} receiveValue: { value in
				self.announceData = value.data ?? []
			}
			.store(in: &cancellables)

	}
	
	func refreshToken(onComplete: @escaping (() -> Void)) {
		onStartRefresh()
		
		let refreshToken = authRepository.loadFromKeychain(forKey: KeychainKey.refreshToken)
		
		authRepository
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
	
	func getUsers() {
		onStartedFetch()
		
		userRepository
			.provideGetUsers()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getUsers ?? {})
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
			} receiveValue: { value in
				self.userData = value
				self.nameOfUser = value.name
				self.photoProfile = value.profilePhoto

				OneSignal.setExternalUserId(value.id.orEmpty())
				OneSignal.sendTag("isTalent", value: "true")
				
				withAnimation {
					self.showingPasswordAlert = !(value.isPasswordFilled ?? false)
				}
			}
			.store(in: &cancellables)
		
	}
}
