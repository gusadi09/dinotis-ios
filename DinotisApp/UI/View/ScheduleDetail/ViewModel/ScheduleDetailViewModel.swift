//
//  ScheduleDetailViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/02/22.
//

import Foundation
import Combine
import SwiftUI
import DinotisData
import DinotisDesignSystem

enum ScheduleDetailTooltip {
    case review
}

extension ScheduleDetailTooltip {
    var value: String {
        switch self {
        case .review:
            return "review"
        }
    }
}

final class ScheduleDetailViewModel: ObservableObject {

    private let getRulesUseCase: GetRulesUseCase
    private let meetingsRepo: MeetingsRepository
    private let getBookingDetailUseCase: GetBookingDetailUseCase
    private let getUserUseCase: GetUserUseCase
    private let authRepo: AuthenticationRepository
	private let confirmationUseCase: RequestConfirmationUseCase
	private let conversationTokenUseCase: ConversationTokenUseCase
    private let giveReviewUseCase: GiveReviewUseCase
    private let stateObservable = StateObservable.shared
    private var cancellables = Set<AnyCancellable>()
	private let isActiveBooking: Bool
    private let startMeetingUseCase: StartCreatorMeetingUseCase
    private let getDetailMeetingUseCase: GetMeetingDetailUseCase
    private let endMeetingUseCase: EndCreatorMeetingUseCase
    private let deleteMeetingUseCase: DeleteCreatorMeetingUseCase

    @Published var currentTooltip: ScheduleDetailTooltip?
	@Published var confirmationSheet = false

    @Published var goToEdit = false

    @Published var isRestricted = false

    @Published var totalPrice = 0

    @Published var isDeleteShow = false

    @Published var isEndShow = false

    @Published var startPresented = false

    @Published var participantDetail = [UserResponse]()
    
    @Published var meetingForm = MeetingForm(id: String.random(), title: "", description: "", price: 10000, startAt: "", endAt: "", isPrivate: true, slots: 0, urls: [])
    
    @Published var randomId = UInt.random(in: .init(1...99999999))

    @Published var conteOffset = CGFloat.zero

    @Published var tabColor = Color.clear

    @Published var presentDelete = false

    @Published var bookingId: String

    @Published var isLoadingDetail = false
    @Published var successDetail = false

	@Published var isLoadingStart = false

    @Published var isLoading = false
    @Published var isLoadingReview = false
    @Published var isError = false
    @Published var success = false
    @Published var error: String?
    @Published var HTMLContent = ""
    @Published var dataMeeting: MeetingDetailResponse?
    @Published var dataBooking: UserBookingData?

	@Published var tokenConversation = ""
	@Published var expiredData = Date()

    @Published var isRefreshFailed = false

    @Published var isShowingRules = false
    @Published var isShowCollabList = false
    @Published var isNotApproved = false
    @Published var isShowAttachments = false
    @Published var isShowWebView = false
    @Published var isTextComplete = false
    @Published var attachmentURL = ""
    
    @Published var showAlreadyReview = false
    @Published var showReviewSheet = false
    @Published var reviewRating = 0
    @Published var reviewMessage = ""
    
    var backToHome: () -> Void
    
    @Published var route: HomeRouting?

    @Published var user: UserResponse?

    @Published var isEndSuccess = false
    @Published var isDeleteSuccess = false

	@Published var cancelOptionData = [CancelOptionData]()

	@Published var successConfirm: Bool = false
	@Published var isLoadingConfirm = false
    
    @Published var talentName: String
    @Published var talentPhoto: String
    
    @Published var isDirectToHome: Bool
    
    init(
		isActiveBooking: Bool,
        getRulesUseCase: GetRulesUseCase = GetRulesDefaultUseCase(),
        meetingsRepo: MeetingsRepository = MeetingsDefaultRepository(),
        getBookingDetailUseCase: GetBookingDetailUseCase = GetBookingDetailDefaultUseCase(),
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        authRepo: AuthenticationRepository = AuthenticationDefaultRepository(),
		confirmationUseCase: RequestConfirmationUseCase = RequestConfirmationDefaultUseCase(),
		conversationTokenUseCase: ConversationTokenUseCase = ConversationTokenDefaultUseCase(),
        giveReviewUseCase: GiveReviewUseCase = GiveReviewDefaultUseCase(),
        startMeetingUseCase: StartCreatorMeetingUseCase = StartCreatorMeetingDefaultUseCase(),
        getDetailMeetingUseCase: GetMeetingDetailUseCase = GetMeetingDetailDefaultUseCase(),
        endMeetingUseCase: EndCreatorMeetingUseCase = EndCreatorMeetingDefaultUseCase(),
        deleteMeetingUseCase: DeleteCreatorMeetingUseCase = DeleteCreatorMeetingDefaultUseCase(),
        bookingId: String,
        backToHome: @escaping (() -> Void),
        talentName: String = "",
        talentPhoto: String = "",
        isDirectToHome: Bool
    ) {
		self.isActiveBooking = isActiveBooking
        self.getRulesUseCase = getRulesUseCase
        self.meetingsRepo = meetingsRepo
        self.getBookingDetailUseCase = getBookingDetailUseCase
        self.getUserUseCase = getUserUseCase
        self.authRepo = authRepo
        self.bookingId = bookingId
        self.backToHome = backToHome
		self.confirmationUseCase = confirmationUseCase
		self.conversationTokenUseCase = conversationTokenUseCase
        self.talentName = talentName
        self.talentPhoto = talentPhoto
        self.isDirectToHome = isDirectToHome
        self.giveReviewUseCase = giveReviewUseCase
        self.startMeetingUseCase = startMeetingUseCase
        self.getDetailMeetingUseCase = getDetailMeetingUseCase
        self.endMeetingUseCase = endMeetingUseCase
        self.deleteMeetingUseCase = deleteMeetingUseCase
    }
    
    func onStartRequestReview() {
        DispatchQueue.main.async {[weak self] in
            withAnimation(.spring()) {
                self?.isError = false
                self?.isLoadingReview = true
                self?.error = nil
                self?.isRefreshFailed = false
            }
        }
    }
    
    func giveReview() async {
        onStartRequestReview()
        
        let body = ReviewRequestBody(rating: self.reviewRating, review: self.reviewMessage, meetingId: (self.dataBooking?.meeting?.id).orEmpty())
        let result = await giveReviewUseCase.execute(with: body)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                withAnimation(.spring()) {
                    self?.isError = false
                    self?.isLoadingReview = false
                    self?.error = nil
                    self?.showReviewSheet = false
                }
            }
            
            await getDetailBookingUser()
            
        case .failure(let failure):
            if let failure = failure as? ErrorResponse {
                DispatchQueue.main.async { [weak self] in
                    withAnimation(.spring()) {
                        self?.isError = true
                        self?.isLoadingReview = false
                        self?.error = failure.message.orEmpty()
                        self?.showReviewSheet = false
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    withAnimation(.spring()) {
                        self?.isError = true
                        self?.isLoadingReview = false
                        self?.error = failure.localizedDescription
                        self?.showReviewSheet = false
                    }
                }
            }
        }
    }

    func onGetMeetingRules() {
        Task {
            await getMeetingRules()
        }
    }
    
    func onGetUser() {
        Task {
            await getUser()
        }
    }
    
    func onGetDetailBooking() {
        Task {
            await getDetailBookingUser()
        }
    }
    func onAppearView() {
        onGetMeetingRules()
        onGetUser()
        onGetDetailBooking()
    }
    
    @MainActor
    func onStartFetch() {
        self.error = nil
        self.success = false
        self.isError = false
        self.isLoading = true
        self.isEndSuccess = false
        self.isDeleteSuccess = false
    }
    
    func disableStartButton() -> Bool {
        return (dataBooking?.meeting?.startAt).orCurrentDate().addingTimeInterval(-280) > Date()
    }
    
    func reviewStars() -> Int {
        guard let rating = self.dataBooking?.meeting?.reviews?.first(where: { item in
            item.userId == user?.id
        })?.rating else { return 0 }
        
        return rating
    }
    
    func isShowRating() -> Bool {
        (self.dataBooking?.status).orEmpty() == SessionStatus.notReviewed.rawValue || (self.dataBooking?.status).orEmpty() == SessionStatus.done.rawValue
    }
    
    func isDone() -> Bool {
        (self.dataBooking?.status).orEmpty() == SessionStatus.done.rawValue
    }

    @MainActor
    func onStartFetchDetail() {
        self.error = nil
        self.successDetail = false
        self.isError = false
        self.isLoadingDetail = true
    }

    @MainActor
    func getUser() async {
        onStartFetch()
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.user = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }

    @MainActor
	func handleDefaultError(error: Error) {
            self.isLoading = false
			self.isLoadingDetail = false

			if let error = error as? ErrorResponse {
				self.error = error.message.orEmpty()

				if error.statusCode.orZero() == 401 {
					self.isRefreshFailed.toggle()
				} else {
					self.isError = true
				}
			} else {
				self.isError = true
				self.error = error.localizedDescription
			}
	}

    @MainActor
	func getDetailBookingUser() async {
        onStartFetchDetail()

		let result = await getBookingDetailUseCase.execute(by: bookingId)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.successDetail = true
				self?.isLoadingDetail = false
                self?.currentTooltip = .review
				self?.dataBooking = success
				self?.expiredData = (success.meeting?.meetingRequest?.expiredAt).orCurrentDate()
				self?.participantDetail = success.meeting?.participantDetails ?? []
			}

			if success.meeting?.meetingRequest != nil && ((success.meeting?.meetingRequest?.isAccepted ?? false) && (success.meeting?.meetingRequest?.isConfirmed == nil)) {
				if (self.tokenConversation).isEmpty {
					await self.getConversationToken(id: (success.meeting?.meetingRequest?.id).orEmpty())
				}
			}
		case .failure(let failure):
			handleDefaultError(error: failure)
		}

    }
    
    func getDetailMeeting() async {
        await onStartFetchDetail()
        
        let result = await getDetailMeetingUseCase.execute(for: bookingId)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.successDetail = true
                self?.isLoadingDetail = false
                
                self?.dataMeeting = success
                self?.expiredData = (success.meetingRequest?.expiredAt).orCurrentDate()
                self?.cancelOptionData = success.cancelOptions ?? []
                
                if success.meetingRequest != nil && ((success.meetingRequest?.isAccepted ?? false) && (success.meetingRequest?.isConfirmed == nil)) {
                    if (self?.tokenConversation.isEmpty ?? false) {
                        Task {
                            await self?.getConversationToken(id: (success.meetingRequest?.id).orEmpty())
                        }
                    }
                }
            }
        case .failure(let failure):
            await handleDefaultError(error: failure)
        }
    }
    
    func endMeeting() async {
        await onStartFetch()
        
        let result = await endMeetingUseCase.execute(for: bookingId)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isEndSuccess = true
                self?.isLoading = false
            }
        case .failure(let failure):
            await handleDefaultError(error: failure)
        }
    }

    func deleteMeeting() async {
        await onStartFetch()
        
        let result = await deleteMeetingUseCase.execute(for: bookingId)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isDeleteSuccess = true
                self?.isLoading = false
            }
        case .failure(let failure):
            await handleDefaultError(error: failure)
        }
        
    }

    @MainActor
    func getMeetingRules() async {
        onStartFetch()

        let result = await getRulesUseCase.execute()
        
        switch result {
        case .success(let success):
            self.success = true
            isLoading = false
            HTMLContent = success.content.orEmpty()
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }

    func onStartRefresh() {
        DispatchQueue.main.async { [weak self] in
            self?.isRefreshFailed = false
            self?.isLoading = true
            self?.success = false
            self?.error = nil
        }

    }

    func convertToUserMeet(meet: MeetingDetailResponse) -> UserMeetingData {
        let meet = UserMeetingData(
            id: meet.id,
            title: meet.title.orEmpty(),
            meetingDescription: meet.description.orEmpty(),
            price: meet.price.orEmpty(),
			startAt: meet.startAt.orCurrentDate(),
			endAt: meet.endAt.orCurrentDate(),
            isPrivate: meet.isPrivate,
            isLiveStreaming: meet.isLiveStreaming,
			slots: meet.slots,
			participants: meet.participants,
            userID: meet.user?.id,
            startedAt: meet.startedAt,
            endedAt: meet.endedAt,
            createdAt: meet.createdAt,
            updatedAt: meet.updatedAt,
            deletedAt: meet.deletedAt,
            bookings: [],
            user: meet.user,
			participantDetails: [],
			meetingBundleId: meet.meetingBundleId,
			meetingRequestId: meet.meetingRequestId,
			status: meet.status,
			meetingRequest: nil,
            expiredAt: meet.meetingRequest?.expiredAt,
            background: [""],
            meetingCollaborations: meet.meetingCollaborations,
            meetingUrls: meet.meetingUrls,
            meetingUploads: meet.meetingUploads,
            roomSid: meet.roomSid,
            dyteMeetingId: meet.dyteMeetingId,
            isInspected: meet.isInspected,
            reviews: meet.reviews
        )

        return meet
    }
    
    func routeToVideoCall(meeting: UserMeetingData) {
        let viewModel = PrivateVideoCallViewModel(meeting: meeting, backToHome: self.backToHome)
        
        DispatchQueue.main.async {[weak self] in
            self?.route = .videoCall(viewModel: viewModel)
        }
    }

	func routeToEditSchedule() {
		let viewModel = EditTalentMeetingViewModel(meetingID: bookingId, backToHome: self.backToHome)

		DispatchQueue.main.async {[weak self] in
			self?.route = .editScheduleMeeting(viewModel: viewModel)
		}
	}
    
    func routeToEditRateCardSchedule() {
        let viewModel = TalentEditRateCardScheduleViewModel(meetingID: bookingId, backToHome: self.backToHome)

        DispatchQueue.main.async {[weak self] in
            self?.route = .editRateCardSchedule(viewModel: viewModel)
        }
    }
    
    func routeToScheduleNegotiationChat() {
		let viewModel = ScheduleNegotiationChatViewModel(token: tokenConversation, expireDate: expiredData, backToHome: {self.route = nil})
        
        DispatchQueue.main.async {[weak self] in
            self?.route = .scheduleNegotiationChat(viewModel: viewModel)
        }
    }
    
    func routeToGroupCall(meeting: UserMeetingData) {
        let viewModel = GroupVideoCallViewModel(
            backToHome: self.backToHome,
            backToScheduleDetail: {self.route = nil},
            userMeeting: meeting
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .dyteGroupVideoCall(viewModel: viewModel)
        }
    }
    
    func routeToTwilioLiveStream(meeting: UserMeetingData) {
        let viewModel = TwilioLiveStreamViewModel(
            backToHome: self.backToHome,
            meeting: meeting
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .twilioLiveStream(viewModel: viewModel)
        }
    }

  
    func routeToTalentProfile(username: String?) {
        let viewModel = TalentProfileDetailViewModel(backToHome: {self.route = nil}, username: username.orEmpty())
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .talentProfileDetail(viewModel: viewModel)
        }
    }

    @MainActor
	func getConversationToken(id: String) async {
		onStartFetchDetail()

		let result = await conversationTokenUseCase.execute(with: id)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.successDetail = true
				self?.isLoadingDetail = false
				self?.tokenConversation = success.token.orEmpty()
			}
		case .failure(let failure):
			handleDefaultError(error: failure)
		}
	}

	func isPaymentDone(status: String) -> Bool {
		status == "payment_done" || status == "waiting_creator_confirmation" || status == "schedule_confirmed" || status == "schedule_started" || status == "schedule_ended"
	}

	func isWaitingCreatorConfirmationDone(status: String, isAccepted: Bool?) -> Bool {
		(
			status == "waiting_creator_confirmation" || status == "schedule_confirmed" || status == "schedule_started" || status == "schedule_ended"
		) && (isAccepted ?? false)
	}

	func isWaitingCreatorConfirmationPending(status: String, isAccepted: Bool?) -> Bool {
		(
			status == "payment_done" || status == "waiting_creator_confirmation" || status == "schedule_confirmed" || status == "schedule_started" || status == "schedule_ended"
		) && isAccepted == nil
	}

	func isWaitingCreatorConfirmationFailed(status: String, isAccepted: Bool?) -> Bool {
		(
			status == "waiting_creator_confirmation" || status == "schedule_confirmed" || status == "schedule_started" || status == "schedule_ended"
		) && !(isAccepted ?? false)
	}

	func isScheduleConfirmationDone(status: String, isConfirmed: Bool?) -> Bool {
		(
			status == "schedule_confirmed" || status == "schedule_started" || status == "schedule_ended"
		) && (isConfirmed ?? false)
	}

	func isScheduleConfirmationPending(status: String, isConfirmed: Bool?) -> Bool {
		(
			status == "waiting_creator_confirmation" || status == "schedule_confirmed" || status == "schedule_started" || status == "schedule_ended"
		) && isConfirmed == nil
	}

	func isScheduleConfirmationFailed(status: String, isConfirmed: Bool?) -> Bool {
		(
			status == "schedule_confirmed" || status == "schedule_started" || status == "schedule_ended"
		) && !(isConfirmed ?? false)
	}

	func isScheduleStartedDone(status: String) -> Bool {
		(
			status == "schedule_started" || status == "schedule_ended"
		)
	}

	func isScheduleEndedDone(status: String) -> Bool {
		(
			status == "schedule_ended"
		)
	}

	func isAllStateFailed(status: String, isAccepted: Bool?, isConfirmed: Bool?) -> Bool {
		isScheduleConfirmationFailed(status: status, isConfirmed: isConfirmed) || isWaitingCreatorConfirmationFailed(status: status, isAccepted: isAccepted)
	}

	func onStartConfirm() {
		DispatchQueue.main.async {[weak self] in
			self?.isError = false
			self?.isLoadingConfirm = true
			self?.error = nil
			self?.successConfirm = false
			self?.confirmationSheet = false
		}
	}

	func handleDefaultErrorConfirm(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoadingConfirm = false
			self?.confirmationSheet = false

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

		let result = await confirmationUseCase.execute(with: (self.dataMeeting?.meetingRequest?.id).orEmpty(), contain: body)

		switch result {
		case .success(_):
			DispatchQueue.main.async { [weak self] in
				self?.successConfirm = true
				self?.isLoadingConfirm = false
			}
		case .failure(let failure):
			handleDefaultErrorConfirm(error: failure)
		}
	}

	func isShowingChatButton() -> Bool {
		((dataMeeting?.meetingRequest?.isAccepted ?? false) && (dataMeeting?.meetingRequest?.isConfirmed == nil)) || ((dataBooking?.meeting?.meetingRequest?.isAccepted ?? false) && (dataBooking?.meeting?.meetingRequest?.isConfirmed == nil))
	}
    
    @MainActor
    func onStartMeeting() {
        self.error = nil
        self.isError = false
        self.isLoadingStart = true
    }

    @MainActor
	func startMeeting() async {
		onStartMeeting()

        let result = await startMeetingUseCase.execute(for: bookingId)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoadingStart = false
                self?.startPresented.toggle()

                guard let detailMeet = self?.dataMeeting else { return }
                guard let converted = self?.convertToUserMeet(meet: detailMeet) else { return }

                if detailMeet.isPrivate ?? false {
                    self?.routeToVideoCall(meeting: converted)
                } else if !(detailMeet.isPrivate ?? false) {
                    if detailMeet.dyteMeetingId == nil {
                        self?.routeToTwilioLiveStream(meeting: converted)
                    } else {
                        self?.routeToGroupCall(
                            meeting: converted
                        )
                    }
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
	}
}
