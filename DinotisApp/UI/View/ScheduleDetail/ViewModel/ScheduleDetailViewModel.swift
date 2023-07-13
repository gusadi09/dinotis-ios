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

final class ScheduleDetailViewModel: ObservableObject {

    private let meetingsRepo: MeetingsRepository
    private let getBookingDetailUseCase: GetBookingDetailUseCase
    private let getUserUseCase: GetUserUseCase
    private let authRepo: AuthenticationRepository
	private let confirmationUseCase: RequestConfirmationUseCase
	private let conversationTokenUseCase: ConversationTokenUseCase
    private let stateObservable = StateObservable.shared
    private var cancellables = Set<AnyCancellable>()
	private let isActiveBooking: Bool

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
    @Published var isError = false
    @Published var success = false
    @Published var error: String?
    @Published var HTMLContent = ""
    @Published var dataMeeting: DetailMeeting?
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
    
    var backToRoot: () -> Void
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
        meetingsRepo: MeetingsRepository = MeetingsDefaultRepository(),
        getBookingDetailUseCase: GetBookingDetailUseCase = GetBookingDetailDefaultUseCase(),
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        authRepo: AuthenticationRepository = AuthenticationDefaultRepository(),
		confirmationUseCase: RequestConfirmationUseCase = RequestConfirmationDefaultUseCase(),
		conversationTokenUseCase: ConversationTokenUseCase = ConversationTokenDefaultUseCase(),
        bookingId: String,
        backToRoot: @escaping (() -> Void),
        backToHome: @escaping (() -> Void),
        talentName: String = "",
        talentPhoto: String = "",
        isDirectToHome: Bool
    ) {
		self.isActiveBooking = isActiveBooking
        self.meetingsRepo = meetingsRepo
        self.getBookingDetailUseCase = getBookingDetailUseCase
        self.getUserUseCase = getUserUseCase
        self.authRepo = authRepo
        self.bookingId = bookingId
        self.backToRoot = backToRoot
        self.backToHome = backToHome
		self.confirmationUseCase = confirmationUseCase
		self.conversationTokenUseCase = conversationTokenUseCase
        self.talentName = talentName
        self.talentPhoto = talentPhoto
        self.isDirectToHome = isDirectToHome
    }

    func onAppearView() {
		Task {
			self.getMeetingRules()
			await self.getUser()
			await self.getDetailBookingUser()
		}
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
    
    func disableStartButton() -> Bool {
        return (dataBooking?.meeting?.startAt).orCurrentDate().addingTimeInterval(-280) > Date()
    }

    func onStartFetchDetail() {
        DispatchQueue.main.async { [weak self] in
            self?.error = nil
            self?.successDetail = false
            self?.isError = false
            self?.isLoadingDetail = true
        }
    }

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

	func handleDefaultError(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoadingDetail = false

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

	func getDetailBookingUser() async {
        onStartFetchDetail()

		let result = await getBookingDetailUseCase.execute(by: bookingId)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.successDetail = true
				self?.isLoadingDetail = false

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

	func getDetailMeeting() {
        onStartFetchDetail()

        meetingsRepo.provideGetDetailMeeting(meetingId: bookingId)
            .sink { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {[weak self] in
                        if error.statusCode.orZero() == 401 {
                            
                        } else {
                            self?.isError = true
                            self?.isLoadingDetail = false

                            self?.error = error.message.orEmpty()
                        }
                    }

                case .finished:
                    DispatchQueue.main.async { [weak self] in
                        self?.successDetail = true
                        self?.isLoadingDetail = false
                    }
                }
            } receiveValue: { value in
                self.dataMeeting = value
				self.expiredData = (value.meetingRequest?.expiredAt).orCurrentDate()
				self.cancelOptionData = value.cancelOptions ?? []

				Task {
					if value.meetingRequest != nil && ((value.meetingRequest?.isAccepted ?? false) && (value.meetingRequest?.isConfirmed == nil)) {
						if self.tokenConversation.isEmpty {
							await self.getConversationToken(id: (value.meetingRequest?.id).orEmpty())
						}
					}
				}
            }
            .store(in: &cancellables)
    }

    func endMeeting() {
        onStartFetch()

        meetingsRepo.providePatchEndMeeting(by: bookingId)
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
                           
                        } else {
                            self?.isError = true
                            self?.isLoading = false

                            self?.error = error.message.orEmpty()
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

    func convertToUserMeet(meet: DetailMeeting) -> UserMeetingData {
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
            userID: meet.userID,
            startedAt: meet.startedAt,
            endedAt: meet.endedAt,
            createdAt: meet.createdAt,
            updatedAt: meet.updatedAt,
            deletedAt: meet.deletedAt,
            bookings: [],
			user: nil,
			participantDetails: [],
			meetingBundleId: meet.meetingBundleId,
			meetingRequestId: meet.meetingRequestId,
			status: meet.status,
			meetingRequest: nil,
            expiredAt: meet.meetingRequest?.expiredAt,
            background: [""],
            meetingCollaborations: meet.meetingCollaborations,
            meetingUrls: meet.meetingUrls,
            meetingUploads: meet.meetingUploads
        )

        return meet
    }
    
    func routeToVideoCall(meeting: UserMeetingData) {
        let viewModel = PrivateVideoCallViewModel(meeting: meeting, backToRoot: self.backToRoot, backToHome: self.backToHome)
        
        DispatchQueue.main.async {[weak self] in
            self?.route = .videoCall(viewModel: viewModel)
        }
    }

	func routeToEditSchedule() {
		let viewModel = EditTalentMeetingViewModel(meetingID: bookingId, backToRoot: self.backToRoot, backToHome: self.backToHome)

		DispatchQueue.main.async {[weak self] in
			self?.route = .editScheduleMeeting(viewModel: viewModel)
		}
	}
    
    func routeToEditRateCardSchedule() {
        let viewModel = TalentEditRateCardScheduleViewModel(meetingID: bookingId, backToRoot: self.backToRoot, backToHome: self.backToHome)

        DispatchQueue.main.async {[weak self] in
            self?.route = .editRateCardSchedule(viewModel: viewModel)
        }
    }
    
    func routeToScheduleNegotiationChat() {
		let viewModel = ScheduleNegotiationChatViewModel(token: tokenConversation, expireDate: expiredData, backToRoot: self.backToRoot, backToHome: {self.route = nil})
        
        DispatchQueue.main.async {[weak self] in
            self?.route = .scheduleNegotiationChat(viewModel: viewModel)
        }
    }
    
    func routeToTwilioLiveStream(meeting: UserMeetingData) {
        let viewModel = TwilioLiveStreamViewModel(
            backToRoot: self.backToRoot,
            backToHome: self.backToHome,
            meeting: meeting
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .twilioLiveStream(viewModel: viewModel)
        }
    }
    
    func routeToResearch(meeting: UserMeetingData) {
        let viewModel = GroupVideoCallViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome, userMeeting: meeting)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .research(viewModel: viewModel)
        }
    }
  
    func routeToTalentProfile(username: String?) {
        let viewModel = TalentProfileDetailViewModel(backToRoot: self.backToRoot, backToHome: {self.route = nil}, username: username.orEmpty())
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .talentProfileDetail(viewModel: viewModel)
        }
    }

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

	func onStartMeeting() {
		DispatchQueue.main.async { [weak self] in
			self?.error = nil
			self?.isError = false
			self?.isLoadingStart = true
		}
	}

	func startMeeting() {
		onStartMeeting()

		meetingsRepo.providePatchStartTalentMeeting(by: bookingId)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							
						} else {
							self?.isError = true
							self?.isLoadingStart = false

							self?.error = error.message.orEmpty()
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isLoadingStart = false
						self?.startPresented.toggle()

						guard let detailMeet = self?.dataMeeting else { return }
						guard let converted = self?.convertToUserMeet(meet: detailMeet) else { return }

						if detailMeet.isPrivate ?? false {
							self?.routeToVideoCall(meeting: converted)
						} else if !(detailMeet.isPrivate ?? false) {
							self?.routeToTwilioLiveStream(
								meeting: converted
							)
						}
					}
				}
			} receiveValue: { _ in

			}
			.store(in: &cancellables)
	}
}
