//
//  HomeViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import DinotisDesignSystem
import SwiftUI
import Combine
import DinotisData
import OneSignal

enum TalentHomeSection {
    case scheduled
    case notConfirmed
    case pending
    case canceled
    case completed
}

enum CreatorHomeAlertType {
    case deleteSelector
    case error
    case deleteSuccess
    case refreshFailed
    case confirmationSuccess
}

final class TalentHomeViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()

	private let rateCardRepository: RateCardRepository
    private lazy var stateObservable = StateObservable.shared
    private let getUserUseCase: GetUserUseCase
    private let currentBalanceUseCase: CurrentBalanceUseCase
    private let getAnnouncementUseCase: GetAnnouncementUseCase
	private let confirmationUseCase: RequestConfirmationUseCase
	private let meetingRequestUseCase: MeetingRequestUseCase
    private let counterUseCase: GetCounterUseCase
    private let getTalentMeetingUseCase: GetCreatorMeetingListUseCase
    private let deleteMeetingUseCase: DeleteCreatorMeetingUseCase
    private let getTalentMeetingWithStatusUseCase: GetCreatorMeetingWithStatusListUseCase
    private let getClosestSessionUseCase: GetClosestSessionUseCase

    @Published var isShowAlert = false
    @Published var alertType: CreatorHomeAlertType = .error
    @Published var isFromUserType: Bool
    @Published var hasNewNotif = false
    @Published var notificationBadgeCountStr = ""
	@Published var confirmationSheet: MeetingRequestAcceptanceSelection? = nil
    @Published var filterSelection = ""
	@Published var filterSelectionRequest = ""
    private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
    @Published var filterOption = [OptionQueryResponse]()
    @Published var meetingData = [MeetingDetailResponse]()
    
    @Published var isLoadingMoreScheduled = false
    @Published var isLoadingMorePending = false
    @Published var isLoadingMoreEnded = false
    @Published var isLoadingMoreCancelled = false
    
    @Published var scheduledRequest = MeetingsStatusPageRequest(take: 8, skip: 0, status: "scheduled", sort: "desc")
    @Published var pendingRequest = MeetingsStatusPageRequest(take: 8, skip: 0, status: "pending", sort: "desc")
    @Published var endedRequest = MeetingsStatusPageRequest(take: 8, skip: 0, status: "ended", sort: "desc")
    @Published var canceledRequest = MeetingsStatusPageRequest(take: 8, skip: 0, status: "canceled", sort: "desc")
    
    @Published var scheduledData = [MeetingDetailResponse]()
    @Published var scheduledCounter: String? = nil
    @Published var pendingData = [MeetingDetailResponse]()
    @Published var pendingCounter: String? = nil
    @Published var endedData = [MeetingDetailResponse]()
    @Published var endedCounter: String? = nil
    @Published var canceledData = [MeetingDetailResponse]()
    @Published var canceledCounter: String? = nil
    
    var creatorSessions: [MeetingDetailResponse] {
        switch currentSection {
        case .scheduled:
            return meetingData.filter { meeting in
                meeting.endedAt == nil &&
                (meeting.meetingRequest == nil ||
                 meeting.meetingRequest?.isConfirmed == true)
            }
        case .notConfirmed:
            return meetingData.filter { meeting in
                meeting.meetingRequest?.isConfirmed == nil
            }
        case .pending:
            return meetingData.filter { meeting in
                meeting.meetingRequest?.isConfirmed == nil &&
                meeting.meetingRequest?.isAccepted == true &&
                meeting.meetingRequest != nil
            }
        case .canceled:
            return meetingData.filter { meeting in
                meeting.meetingRequest?.isConfirmed == false ||
                meeting.meetingRequest?.isAccepted == false
            }
        case .completed:
            return meetingData.filter { meeting in
                meeting.endedAt != nil
            }
        }
    }
    
    func pendingStatus(of meeting: MeetingDetailResponse) -> CreatorSessionStatus {
        if meeting.meetingRequest?.isConfirmed == nil {
            return .unconfirmed
        } else {
            return .waitingNewSchedule
        }
    }
    
    @Published var meetingParam = MeetingsPageRequest(take: 15, skip: 0, isStarted: "", isEnded: "false", isAvailable: "true")
    
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
    @Published var isLoadingMore = false
    @Published var isLoadingMoreRequest = false

	@Published var successConfirm: Bool = false
	@Published var isLoadingConfirm = false

	@Published var requestId = ""
    @Published var requestMeetingId = ""

    @Published var announceData = [AnnouncementData]()
    @Published var announceIndex = 0
    
    @Published var tabNumb = 0
    
    @Published var isShowAdditionalContent = false
    @Published var tabSections: [TalentHomeSection] = [
        .scheduled, .notConfirmed, .pending, .canceled, .completed
    ]
    @Published var currentSection: TalentHomeSection = .scheduled
    
    @Published var isSortByLatestNotConfirmed = true
    @Published var isSortByLatestPending = true
    @Published var isSortByLatestCanceled = true
    @Published var isSortByLatestEnded = true
    
    @Published var translation: CGSize = .zero
    @Published var offsetY: CGFloat = 550
    var sheetHeight: CGFloat {
        !closestSessions.isEmpty ? 562 : 320
    }
    
    @Published var closestSessions = [MeetingDetailResponse]()
    
    init(
        isFromUserType: Bool,
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        currentBalanceUseCase: CurrentBalanceUseCase = CurrentBalanceDefaultUseCase(),
        getAnnouncementUseCase: GetAnnouncementUseCase = GetAnnouncementDefaultUseCase(),
		rateCardRepository: RateCardRepository = RateCardDefaultRepository(),
		confirmationUseCase: RequestConfirmationUseCase = RequestConfirmationDefaultUseCase(),
        meetingRequestUseCase: MeetingRequestUseCase = MeetingRequestDefaultUseCase(),
        counterUseCase: GetCounterUseCase = GetCounterDefaultUseCase(),
        getTalentMeetingUseCase: GetCreatorMeetingListUseCase = GetCreatorMeetingListDefaultUseCase(),
        deleteMeetingUseCase: DeleteCreatorMeetingUseCase = DeleteCreatorMeetingDefaultUseCase(),
        getTalentMeetingWithStatusUseCase: GetCreatorMeetingWithStatusListUseCase = GetCreatorMeetingWithStatusListDefaultUseCase(),
        getClosestSessionUseCase: GetClosestSessionUseCase = GetClosestSessionDefaultUseCase()
    ) {
        self.isFromUserType = isFromUserType
        self.getUserUseCase = getUserUseCase
        self.currentBalanceUseCase = currentBalanceUseCase
        self.getAnnouncementUseCase = getAnnouncementUseCase
		self.rateCardRepository = rateCardRepository
		self.confirmationUseCase = confirmationUseCase
		self.meetingRequestUseCase = meetingRequestUseCase
        self.counterUseCase = counterUseCase
        self.getTalentMeetingUseCase = getTalentMeetingUseCase
        self.deleteMeetingUseCase = deleteMeetingUseCase
        self.getTalentMeetingWithStatusUseCase = getTalentMeetingWithStatusUseCase
        self.getClosestSessionUseCase = getClosestSessionUseCase
    }
    
    func getBottomSafeArea() -> CGFloat{
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?.windows
            .filter({ $0.isKeyWindow }).first
        
        return keyWindow?.safeAreaInsets.bottom ?? 0
        
    }
    
    func getClosestSession() async {
        onStartedFetch()
        
        let result = await getClosestSessionUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.closestSessions = success.data ?? []
            }
        case .failure(let error):
            handleDefaultError(error: error)
        }
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
                self?.notificationBadgeCountStr = success.unreadNotificationCount.orZero() > 9 ? "9+" : "\(success.unreadNotificationCount.orZero())"
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func routeToInbox() {
        let viewModel = InboxViewModel()
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .inbox(viewModel: viewModel)
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

    func onGetCounter() {
        Task {
            await self.getCounter()
        }
    }
    
    func onGetCurrentBalance() {
        Task {
            await self.getCurrentBalance()
        }
    }
    
    func onGetTalentMeeting() {
        Task {
            await self.getTalentMeeting(isMore: false)
        }
    }
    
    func onGetMeetingRequest(isMore: Bool) {
        Task {
            await self.getMeetingRequest(isMore: isMore)
        }
    }
    
    func onGetClosestMeeting() {
        Task {
            await self.getClosestSession()
        }
    }
    
    func onAppearView() {
		Task {
			await self.getUsers()
			guard !isRefreshFailed else { return }
            onGetCounter()
            onGetCurrentBalance()
            onGetScheduledMeeting(isMore: false)
            onGetPendingMeeting(isMore: false)
            onGetCanceledMeeting(isMore: false)
            onGetEndedMeeting(isMore: false)
            onGetClosestMeeting()
            onGetMeetingRequest(isMore: false)
		}
    }
    
    func onStartedFetch(isMore: Bool = false) {
        DispatchQueue.main.async {[weak self] in
            self?.isError = false
            if !isMore {
                self?.isLoading = true
            } else {
                self?.isLoadingMore = true
                self?.isLoadingMoreRequest = true
            }
            self?.error = nil
            self?.success = false
        }
    }
    
    func onStartedFetchWithSection(isMore: Bool = false, section: TalentHomeSection) {
        DispatchQueue.main.async {[weak self] in
            self?.isError = false
            if !isMore {
                self?.isLoading = true
            } else {
                switch section {
                case .scheduled:
                    self?.isLoadingMoreScheduled = true
                case .notConfirmed:
                    break
                case .pending:
                    self?.isLoadingMorePending = true
                case .canceled:
                    self?.isLoadingMoreCancelled = true
                case .completed:
                    self?.isLoadingMoreEnded = true
                }
            }
            self?.error = nil
            self?.success = false
        }
    }
    
    func onChangeSortPending(isLatest: Bool) {
        Task {
            pendingRequest.take = 8
            pendingRequest.skip = 0
            pendingRequest.sort = isLatest ? "desc" : "asc"
            
            await getPendingMeeting(isMore: false)
        }
    }
    
    func onChangeSortEnded(isLatest: Bool) {
        Task {
            endedRequest.take = 8
            endedRequest.skip = 0
            endedRequest.sort = isLatest ? "desc" : "asc"
            
            await getEndedMeeting(isMore: false)
        }
    }
    
    func onChangeSortCanceled(isLatest: Bool) {
        Task {
            canceledRequest.take = 8
            canceledRequest.skip = 0
            canceledRequest.sort = isLatest ? "desc" : "asc"
            
            await getCancelledMeeting(isMore: false)
        }
    }
    
    func sortSelectionActionLatest() {
        switch currentSection {
        case .scheduled:
            break
        case .notConfirmed:
            isSortByLatestNotConfirmed = true
        case .pending:
            isSortByLatestPending = true
        case .canceled:
            isSortByLatestCanceled = true
        case .completed:
            isSortByLatestEnded = true
        }
    }
    
    func sortSelectionActionEarliest() {
        switch currentSection {
        case .scheduled:
            break
        case .notConfirmed:
            isSortByLatestNotConfirmed = false
        case .pending:
            isSortByLatestPending = false
        case .canceled:
            isSortByLatestCanceled = false
        case .completed:
            isSortByLatestEnded = false
        }
    }
    
    func sortSectionHiddenValue() -> Bool {
        switch currentSection {
        case .scheduled:
            return false
        case .notConfirmed:
            return isSortByLatestNotConfirmed
        case .pending:
            return isSortByLatestPending
        case .canceled:
            return isSortByLatestCanceled
        case .completed:
            return isSortByLatestEnded
        }
    }
    
    func onStartRefresh() {
        self.isRefreshFailed = false
        self.isLoading = true
        self.success = false
        self.error = nil
    }
    
    func resetParameterQuery() {
        self.scheduledRequest.skip = 0
        self.scheduledRequest.take = 8
        
        self.pendingRequest.skip = 0
        self.pendingRequest.take = 8
        
        self.canceledRequest.skip = 0
        self.canceledRequest.take = 8
        
        self.endedRequest.skip = 0
        self.endedRequest.take = 8
        
        self.rateCardQuery.skip = 0
        self.rateCardQuery.take = 15
        
        self.scheduledData = []
        self.canceledData = []
        self.pendingData = []
        self.endedData = []
        self.meetingRequestData = []
    }
    
    @MainActor
    func refreshList() async {
        Task {
            self.scheduledRequest.skip = 0
            self.scheduledRequest.take = 8
            
            self.pendingRequest.skip = 0
            self.pendingRequest.take = 8
            
            self.canceledRequest.skip = 0
            self.canceledRequest.take = 8
            
            self.endedRequest.skip = 0
            self.endedRequest.take = 8
            
            onAppearView()
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
    
    func getScheduledMeeting(isMore: Bool) async {
        onStartedFetchWithSection(isMore: isMore, section: .scheduled)
        
        let result = await getTalentMeetingWithStatusUseCase.execute(with: scheduledRequest)
        
        switch result {
        case .failure(let error):
            handleDefaultMeetingStatusError(error: error, isMore: isMore, section: .scheduled)
        case .success(let response):
            DispatchQueue.main.async {[weak self] in
                if isMore {
                    self?.scheduledData += response.data ?? []
                    self?.isLoadingMoreScheduled = false
                } else {
                    self?.isLoading = false
                    self?.scheduledData = response.data ?? []
                }
                
                self?.scheduledCounter = response.counter
            }
        }
    }
    
    func onGetScheduledMeeting(isMore: Bool) {
        Task {
            await getScheduledMeeting(isMore: isMore)
        }
    }
    
    func getPendingMeeting(isMore: Bool) async {
        onStartedFetchWithSection(isMore: isMore, section: .pending)
        
        let result = await getTalentMeetingWithStatusUseCase.execute(with: pendingRequest)
        
        switch result {
        case .failure(let error):
            handleDefaultMeetingStatusError(error: error, isMore: isMore, section: .pending)
        case .success(let response):
            DispatchQueue.main.async {[weak self] in
                if isMore {
                    self?.pendingData += response.data ?? []
                    self?.isLoadingMorePending = false
                } else {
                    self?.pendingData = response.data ?? []
                    self?.isLoading = false
                }
                
                self?.pendingCounter = response.counter
            }
        }
    }
    
    func onGetPendingMeeting(isMore: Bool) {
        Task {
            await getPendingMeeting(isMore: isMore)
        }
    }
    
    func getCancelledMeeting(isMore: Bool) async {
        onStartedFetchWithSection(isMore: isMore, section: .canceled)
        
        let result = await getTalentMeetingWithStatusUseCase.execute(with: canceledRequest)
        
        switch result {
        case .failure(let error):
            handleDefaultMeetingStatusError(error: error, isMore: isMore, section: .canceled)
        case .success(let response):
            DispatchQueue.main.async {[weak self] in
                if isMore {
                    self?.canceledData += response.data ?? []
                    self?.isLoadingMoreCancelled = false
                } else {
                    self?.canceledData = response.data ?? []
                    self?.isLoading = false
                }
                
                self?.canceledCounter = response.counter
            }
        }
    }
    
    func onGetCanceledMeeting(isMore: Bool) {
        Task {
            await getCancelledMeeting(isMore: isMore)
        }
    }
    
    func getEndedMeeting(isMore: Bool) async {
        onStartedFetchWithSection(isMore: isMore, section: .completed)
        
        let result = await getTalentMeetingWithStatusUseCase.execute(with: endedRequest)
        
        switch result {
        case .failure(let error):
            handleDefaultMeetingStatusError(error: error, isMore: isMore, section: .completed)
        case .success(let response):
            DispatchQueue.main.async {[weak self] in
                if isMore {
                    self?.endedData += response.data ?? []
                    self?.isLoadingMoreEnded = false
                } else {
                    self?.endedData = response.data ?? []
                    self?.isLoading = false
                }
                
                self?.endedCounter = response.counter
            }
        }
    }
    
    func onGetEndedMeeting(isMore: Bool) {
        Task {
            await getEndedMeeting(isMore: isMore)
        }
    }

    func getTalentMeeting(isMore: Bool) async {
        onStartedFetch(isMore: isMore)

        let result = await getTalentMeetingUseCase.execute(with: meetingParam)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                if isMore {
                    self?.isLoadingMore = false
                } else {
                    self?.isLoading = false
                }
                
                if self?.filterSelection.isEmpty ?? false {
                    self?.filterSelection = (success.filters?.options?.first?.label).orEmpty()
                }
                self?.filterOption = success.filters?.options ?? []
                if isMore {
                    self?.meetingData += success.data?.meetings ?? []
                } else {
                    self?.meetingData = success.data?.meetings ?? []
                }
                self?.meetingCounter = success.counter.orEmpty()

                if success.nextCursor == nil {
                    self?.meetingParam.skip = 0
                    self?.meetingParam.take = 15
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure, isMore: isMore)
        }
    }

    func onStartedDeleteMeeting() {
        DispatchQueue.main.async {[weak self] in
            self?.isErrorAdditionalShow = false
            self?.isLoading = true
            self?.error = nil
            self?.isSuccessDelete = false
        }
    }
    
    func handleDefaultErrorDelete(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
            if let error = error as? ErrorResponse {
                
                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.alertType = .refreshFailed
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.error = error.message.orEmpty()
                    self?.isErrorAdditionalShow = true
                    self?.alertType = .error
                }
            } else {
                self?.isErrorAdditionalShow = true
                self?.error = error.localizedDescription
                self?.alertType = .error
            }
            self?.isShowAlert = true
        }
    }
    
    func deleteMeeting() async {
        onStartedDeleteMeeting()

        let result = await deleteMeetingUseCase.execute(for: meetingId)

        switch result {
        case .success(_):
            
            DispatchQueue.main.async { [weak self] in
                self?.alertType = .deleteSuccess
                self?.isSuccessDelete = true
                self?.isShowAlert = true
                self?.isLoading = false
                
                self?.scheduledRequest.skip = 0
                self?.scheduledRequest.take = 8
            }
            
            await self.getScheduledMeeting(isMore: false)
            await self.getClosestSession()

        case .failure(let failure):
            handleDefaultErrorDelete(error: failure)
        }

    }
    
    func handleDefaultError(error: Error, isMore: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            if isMore {
                self?.isLoadingMore = false
                self?.isLoadingMoreRequest = false
            } else {
                self?.isLoading = false
            }

            if let error = error as? ErrorResponse {

                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.alertType = .refreshFailed
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.error = error.message.orEmpty()
                    self?.alertType = .error
                    self?.isError = true
                }
            } else {
                self?.isError = true
                self?.alertType = .error
                self?.error = error.localizedDescription
            }

            self?.isShowAlert = true
        }
    }
    
    func handleDefaultMeetingStatusError(error: Error, isMore: Bool = false, section: TalentHomeSection) {
        DispatchQueue.main.async { [weak self] in
            if isMore {
                switch section {
                case .scheduled:
                    self?.isLoadingMoreScheduled = false
                case .notConfirmed:
                    break
                case .pending:
                    self?.isLoadingMorePending = false
                case .canceled:
                    self?.isLoadingMoreCancelled = false
                case .completed:
                    self?.isLoadingMoreEnded = false
                }
            } else {
                self?.isLoading = false
            }

            if let error = error as? ErrorResponse {

                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.alertType = .refreshFailed
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.error = error.message.orEmpty()
                    self?.alertType = .error
                    self?.isError = true
                }
            } else {
                self?.alertType = .error
                self?.isError = true
                self?.error = error.localizedDescription
            }
            
            self?.isShowAlert = true
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

    func getMeetingRequest(isMore: Bool) async {
		onStartedFetch(isMore: isMore)

		let result = await meetingRequestUseCase.execute(with: rateCardQuery)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.success = true
				self?.isLoading = false
                self?.isLoadingMoreRequest = false

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
            Task {
                await getTalentMeeting(isMore: false)
            }
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
                await getMeetingRequest(isMore: false)
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
    
    func alertAction() {
        switch alertType {
        case .deleteSelector:
            Task {
                await deleteMeeting()
            }
        case .error:
            break
        case .deleteSuccess:
            break
        case .refreshFailed:
            routeBack()
        case .confirmationSuccess:
            break
        }
    }
    
    func alertButtonText() -> String {
        switch alertType {
        case .deleteSelector:
            return LocaleText.yesDeleteText
        case .error:
            return LocaleText.returnText
        case .deleteSuccess:
            return LocaleText.returnText
        case .refreshFailed:
            return LocaleText.returnText
        case .confirmationSuccess:
            return LocaleText.okText
        }
    }
    
    func alertContent() -> String {
        switch alertType {
        case .deleteSelector:
            return LocaleText.deleteAlertText
        case .error:
            return self.error.orEmpty()
        case .deleteSuccess:
            return LocaleText.meetingDeleted
        case .refreshFailed:
            return LocaleText.sessionExpireText
        case .confirmationSuccess:
            return LocaleText.successConfirmRequestText
        }
    }
    
    func alertContentTitle() -> String {
        switch alertType {
        case .deleteSelector:
            return LocaleText.attention
        case .error:
            return LocaleText.attention
        case .deleteSuccess:
            return LocaleText.successTitle
        case .refreshFailed:
            return LocaleText.attention
        case .confirmationSuccess:
            return LocaleText.successTitle
        }
    }

	func handleDefaultErrorConfirm(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoadingConfirm = false
			self?.confirmationSheet = nil

			if let error = error as? ErrorResponse {
				self?.error = error.message.orEmpty()

				if error.statusCode.orZero() == 401 {
                    self?.alertType = .refreshFailed
					self?.isRefreshFailed.toggle()
				} else {
					self?.isError = true
                    self?.alertType = .error
				}
			} else {
                self?.alertType = .error
				self?.isError = true
				self?.error = error.localizedDescription
			}
            self?.isShowAlert = true
		}
	}

    func confirmRequest(isAccepted: Bool, reasons: [Int]?, otherReason: String?) async {
		onStartConfirm()

		let body = ConfirmationRateCardRequest(isAccepted: isAccepted, reasons: reasons, otherReason: otherReason)

		let result = await confirmationUseCase.execute(with: requestId, contain: body)

		switch result {
		case .success(_):
			DispatchQueue.main.async { [weak self] in
                self?.alertType = .confirmationSuccess
				self?.successConfirm = true
				self?.isLoadingConfirm = false

				self?.meetingRequestData.removeAll()
				self?.scheduledData.removeAll()
				self?.rateCardQuery.skip = 0
				self?.rateCardQuery.take = 15
				self?.scheduledRequest.skip = 0
				self?.scheduledRequest.take = 8

                if isAccepted {
                    self?.routeToTalentDetailSchedule(meetingId: (self?.requestMeetingId).orEmpty())
                }
			}

			Task {
                await self.getMeetingRequest(isMore: false)
                await self.getTalentMeeting(isMore: false)
                await self.getScheduledMeeting(isMore: false)
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
