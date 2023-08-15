//
//  HomeViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import SwiftUI
import Combine
import DinotisData
import OneSignal

final class TalentHomeViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()

	private let rateCardRepository: RateCardRepository
    private lazy var stateObservable = StateObservable.shared
    private let getUserUseCase: GetUserUseCase
    private let currentBalanceUseCase: CurrentBalanceUseCase
    private let getAnnouncementUseCase: GetAnnouncementUseCase
    private let meetRepository: MeetingsRepository
	private let confirmationUseCase: RequestConfirmationUseCase
	private let meetingRequestUseCase: MeetingRequestUseCase
    private let counterUseCase: GetCounterUseCase

    @Published var isFromUserType: Bool
    @Published var hasNewNotif = false
	@Published var confirmationSheet: MeetingRequestAcceptanceSelection? = nil
    @Published var filterSelection = ""
	@Published var filterSelectionRequest = ""
    private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
    @Published var filterOption = [OptionQuery]()
    @Published var meetingData = [Meeting]()
    @Published var meetingParam = MeetingsParams(take: 15, skip: 0, isStarted: "", isEnded: "false", isAvailable: "true")
    
    @Published var photoProfile: String?
    @Published var isShowDelete = false
    @Published var isSuccessDelete = false
  @Published var meetingForm = MeetingForm(id: String.random(), title: "", description: "", price: 10000, startAt: "", endAt: "", isPrivate: true, slots: 0, urls: [])
    @Published var isErrorAdditionalShow = false
    @Published var goToEdit = false
    @Published var talentMeetingError = false

	@Published var rateCardQuery = RateCardFilterRequest()

    @Published var meetingId = ""
    @Published var currentBalances: String = "0"
    
    @Published var isRefreshFailed = false

	@Published var meetingRequestData = [MeetingRequestData]()

	@Published var cancelOptionData = [CancelOptionData]()

	@Published var filterData = [OptionMeetingRequestData]()
	@Published var counterRequest = ""
	@Published var meetingCounter = ""
    
    @Published var nameOfUser: String?
    @Published var userData: UserResponse?
    
    @Published var user = User(id: "", name: "", username: "", email: "", profilePhoto: "", isVerified: false)
    
    @Published var showingPasswordAlert = false
    
    @Published var route: HomeRouting?
    
    @Published var isError: Bool = false
    @Published var error: String?
    @Published var success: Bool = false
    
    @Published var contentOffset = CGFloat.zero
    @Published var isLoading = false

	@Published var successConfirm: Bool = false
	@Published var isLoadingConfirm = false

	@Published var requestId = ""

    @Published var announceData = [AnnouncementData]()
    @Published var announceIndex = 0
    
    @Published var tabNumb = 0
    
    init(
        isFromUserType: Bool,
        backToRoot: @escaping (() -> Void),
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        currentBalanceUseCase: CurrentBalanceUseCase = CurrentBalanceDefaultUseCase(),
        getAnnouncementUseCase: GetAnnouncementUseCase = GetAnnouncementDefaultUseCase(),
        meetRepository: MeetingsRepository = MeetingsDefaultRepository(),
		rateCardRepository: RateCardRepository = RateCardDefaultRepository(),
		confirmationUseCase: RequestConfirmationUseCase = RequestConfirmationDefaultUseCase(),
        meetingRequestUseCase: MeetingRequestUseCase = MeetingRequestDefaultUseCase(),
        counterUseCase: GetCounterUseCase = GetCounterDefaultUseCase()
    ) {
        self.isFromUserType = isFromUserType
        self.backToRoot = backToRoot
        self.getUserUseCase = getUserUseCase
        self.currentBalanceUseCase = currentBalanceUseCase
        self.getAnnouncementUseCase = getAnnouncementUseCase
        self.meetRepository = meetRepository
		self.rateCardRepository = rateCardRepository
		self.confirmationUseCase = confirmationUseCase
		self.meetingRequestUseCase = meetingRequestUseCase
        self.counterUseCase = counterUseCase
    }
    
    func getCounter() async {
        onStartedFetch()
        
        let result = await counterUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.hasNewNotif = success.unreadNotificationCount.orZero() > 0
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func routeToProfile() {
        let viewModel = ProfileViewModel(backToHome: { self.route = nil })
        
        DispatchQueue.main.async { [weak self] in
            if self?.stateObservable.userType == 2 {
                self?.route = .talentProfile(viewModel: viewModel)
            } else {
                self?.route = .userProfile(viewModel: viewModel)
            }
        }
    }
    
    func routeToTalentFormSchedule() {
        let viewModel = ScheculedFormViewModel(backToHome: {self.route = nil})
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .talentFormSchedule(viewModel: viewModel)
        }
    }
    
    func routeToNotification() {
        let viewModel = NotificationViewModel(backToHome: { self.route = nil })

        DispatchQueue.main.async { [weak self] in
            self?.route = .notification(viewModel: viewModel)
        }
    }
    
	func routeToTalentDetailSchedule(meetingId: String) {
        let viewModel = ScheduleDetailViewModel(isActiveBooking: true, bookingId: meetingId, backToHome: {self.route = nil}, isDirectToHome: false)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .talentScheduleDetail(viewModel: viewModel)
        }
    }

	func routeToEditSchedule(id: String) {
		let viewModel = EditTalentMeetingViewModel(meetingID: id, backToHome: { self.route = nil })

		DispatchQueue.main.async {[weak self] in
			self?.route = .editScheduleMeeting(viewModel: viewModel)
		}
	}

    func routeToWallet() {
        let viewModel = TalentWalletViewModel(backToHome: {self.route = nil})
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .talentWallet(viewModel: viewModel)
        }
    }
    
    func routeToBundling() {
        let viewModel = BundlingViewModel(backToHome: {self.route = nil})
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .bundlingMenu(viewModel: viewModel)
        }
    }
    
    func routeToTalentRateCardList() {
        let viewModel = TalentCardListViewModel(backToHome: {self.route = nil})
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .talentRateCardList(viewModel: viewModel)
        }
    }

    func routeBack() {
        NavigationUtil.popToRootView()
        self.stateObservable.userType = 0
        self.stateObservable.isVerified = ""
        self.stateObservable.refreshToken = ""
        self.stateObservable.accessToken = ""
        self.stateObservable.isAnnounceShow = false
        OneSignal.setExternalUserId("")
    }

    func onAppearView() {
		Task {
			await self.getUsers()
			guard !isRefreshFailed else { return }
            await self.getCounter()
			await self.getCurrentBalance()
            self.getTalentMeeting(isMore: false)
			await self.getMeetingRequest()
		}
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
            getTalentMeeting(isMore: false)
            
            Task {
                await getUsers()
                
                await getCurrentBalance()
                
                await getMeetingRequest()
            }
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

    func getTalentMeeting(isMore: Bool) {
        onStartedFetch()

        meetRepository.provideGetTalentMeeting(params: meetingParam)
            .sink { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {[weak self] in
                        if error.statusCode.orZero() == 401 {
                            
                        } else {
                            self?.isError = true
                            self?.isLoading = false

                            self?.error = error.message.orEmpty()
                        }
                    }

                case .finished:
                    DispatchQueue.main.async { [weak self] in
                        self?.success = true
                        self?.isLoading = false
                    }
                }
            } receiveValue: { value in
				if self.filterSelection.isEmpty {
					self.filterSelection = (value.filters?.options?.first?.label).orEmpty()
				}
                self.filterOption = value.filters?.options ?? []
                if isMore {
                    self.meetingData += value.data?.meetings ?? []
                } else {
                    self.meetingData = value.data?.meetings ?? []
                }
				self.meetingCounter = value.counter.orEmpty()

				if value.nextCursor == nil {
					self.meetingParam.skip = 0
					self.meetingParam.take = 15
				}

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
                            
                        } else {
                            self?.isErrorAdditionalShow = true
                            self?.isLoading = false

                            self?.error = error.message.orEmpty()
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
                self.getTalentMeeting(isMore: false)
            }
            .store(in: &cancellables)

    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false

            if let error = error as? ErrorResponse {

                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.error = error.message.orEmpty()
                    self?.isError = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }

        }
    }

    func getCurrentBalance() async {
        onStartedFetch()
        
        let result = await currentBalanceUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.currentBalances = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }

    func getAnnouncement() async {
        onStartedFetch()

        let result = await getAnnouncementUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.announceData = success.data ?? []
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
   
    func getUsers() async {
        onStartedFetch()
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                
                self?.userData = success
                self?.nameOfUser = success.name
                self?.photoProfile = success.profilePhoto
                self?.stateObservable.userId = success.id.orEmpty()

                OneSignal.setExternalUserId(success.id.orEmpty())
                OneSignal.sendTag("isTalent", value: "true")
                
                withAnimation {
                    self?.showingPasswordAlert = !(success.isPasswordFilled ?? false)
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }

	func getMeetingRequest() async {
		onStartedFetch()

		let result = await meetingRequestUseCase.execute(with: rateCardQuery)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.success = true
				self?.isLoading = false

				if (self?.filterSelectionRequest ?? "").isEmpty {
					self?.filterSelectionRequest = (success.filters?.options?.first?.label).orEmpty()
				}

				self?.cancelOptionData = success.cancelOptions ?? []
				self?.meetingRequestData += success.data ?? []
				self?.filterData = success.filters?.options ?? []
				self?.counterRequest = success.counter.orEmpty()

				if success.nextCursor == nil {
					if self?.rateCardQuery.skip == 0 {
						self?.rateCardQuery.skip = 0
						self?.rateCardQuery.take = 15
					} else {
						self?.rateCardQuery.skip -= 15
						self?.rateCardQuery.take -= 15
					}
				}
			}
		case .failure(let failure):
			handleDefaultError(error: failure)
		}
	}

	func filterScheduledMeeting(newValue: String) {
		if let optionLabel = filterOption.firstIndex(where: { query in
			query.label.orEmpty() == newValue
		}) {
			if newValue == filterOption[optionLabel].label.orEmpty() {
				if let isEnded = filterOption[optionLabel].queries?.firstIndex(where: { option in
					option.name.orEmpty() == "is_ended"
				}) {
					meetingParam.isEnded = (filterOption[optionLabel].queries?[isEnded].value).orEmpty()
				} else {
					meetingParam.isEnded = ""
				}

				if let isAvail = filterOption[optionLabel].queries?.firstIndex(where: { option in
					option.name.orEmpty() == "is_available"
				}) {
					meetingParam.isAvailable = (filterOption[optionLabel].queries?[isAvail].value).orEmpty()
				} else {
					meetingParam.isAvailable = ""
				}
			}

			meetingData = []
			meetingParam.skip = 0
			meetingParam.take = 15
            getTalentMeeting(isMore: false)
		}
	}

	func filterMeetingRequest(newValue: String) {
		if let optionLabel = filterData.firstIndex(where: { query in
			query.label.orEmpty() == newValue
		}) {
			if newValue == filterData[optionLabel].label.orEmpty() {
				if let isAccepted = filterData[optionLabel].queries?.firstIndex(where: { option in
					option.name.orEmpty() == "is_accepted"
				}) {
					rateCardQuery.isAccepted = (filterData[optionLabel].queries?[isAccepted].value).orEmpty()
				} else {
					rateCardQuery.isAccepted = ""
				}

				if let isAccepted = filterData[optionLabel].queries?.firstIndex(where: { option in
					option.name.orEmpty() == "is_not_confirmed"
				}) {
					rateCardQuery.isNotConfirmed = (filterData[optionLabel].queries?[isAccepted].value).orEmpty()
				} else {
					rateCardQuery.isNotConfirmed = ""
				}
			}

			meetingRequestData = []
			rateCardQuery.skip = 0
			rateCardQuery.take = 15

			Task {
				await getMeetingRequest()
			}
		}
	}

	func onStartConfirm() {
		DispatchQueue.main.async {[weak self] in
			self?.isError = false
			self?.isLoadingConfirm = true
			self?.error = nil
			self?.successConfirm = false
			self?.confirmationSheet = nil
		}
	}

	func handleDefaultErrorConfirm(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoadingConfirm = false
			self?.confirmationSheet = nil

			if let error = error as? ErrorResponse {
				self?.error = error.message.orEmpty()


				if error.statusCode.orZero() == 401 {
					self?.isRefreshFailed.toggle()
				} else {
					self?.isError = true
				}
			} else {
				self?.isError = true
				self?.error = error.localizedDescription
			}

		}
	}

	func confirmRequest(isAccepted: Bool, reasons: [Int]?, otherReason: String?) async {
		onStartConfirm()

		let body = ConfirmationRateCardRequest(isAccepted: isAccepted, reasons: reasons, otherReason: otherReason)

		let result = await confirmationUseCase.execute(with: requestId, contain: body)

		switch result {
		case .success(_):
			DispatchQueue.main.async { [weak self] in
				self?.successConfirm = true
				self?.isLoadingConfirm = false

				self?.meetingRequestData.removeAll()
				self?.meetingData.removeAll()
				self?.rateCardQuery.skip = 0
				self?.rateCardQuery.take = 15
				self?.meetingParam.skip = 0
				self?.meetingParam.take = 15

                self?.getTalentMeeting(isMore: false)
			}

			Task {
				await self.getMeetingRequest()
			}
		case .failure(let failure):
			handleDefaultErrorConfirm(error: failure)
		}
	}
}

enum MeetingRequestAcceptanceSelection: Identifiable {
	var id: UUID {
		UUID()
	}

	case accepted
	case declined
}
