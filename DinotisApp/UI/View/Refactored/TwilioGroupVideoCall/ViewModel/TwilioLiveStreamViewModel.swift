//
//  TwilioLiveStreamViewModel.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import Foundation
import TwilioVideo
import TwilioLivePlayer
import Combine
import SwiftUI

final class TwilioLiveStreamViewModel: ObservableObject {
	
	private let questionRepository: QuestionRepository
	private let authRepository: AuthenticationRepository
	private let meetRepository: MeetingsRepository
	private let userRepository: UsersRepository
	private let twilioRepo: TwilioDataRepository
	private var cancellables = Set<AnyCancellable>()
	
	var backToRoot: (() -> Void)
	var backToHome: (() -> Void)
	@Published var route: HomeRouting? = nil
	@Published var isShowingToolbar = true
	
	@Published var meeting: UserMeeting
	@Published var userData: Users?
	@Published var questionData = Question()
	@Published var hasUnreadQuestion = false
	
	@Published var isLockAllParticipantAudio = false
	
	@Published var isShowingCloseAlert = false
	@Published var isShowingParticipants = false
	@Published var isShowingChat = false
	@Published var isShowingQnA = false
	@Published var QnASegment = 0
    
    @Published var isButtonActive = false
	
	@Published var questionText = ""
	@Published var messageText = ""
	@Published var spotlightedModel = SpeakerVideoViewModel()
	
	@Published var isShowQuestionBox = false
	@Published var isShowQuestionList = false
	@Published var isAnsweredTab = false
	
	@Published var isLoadingQuestion: Bool = false
	@Published var isErrorQuestion: Bool = false
	@Published var errorQuestion: HMError?
	@Published var successQuestion: Bool = false
	@Published var questionResponse: QuestionResponse?
	
	@Published var isRefreshFailed = false
	@Published var isLoading: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false
	@Published var isError = false
	
	@Published var isMuteOnlyUser = false
	
	@Published var showingMoreMenu = false
	@Published var showSetting = false
	
	@Published var isStarted = false
	@Published var isShowingAbout = false
	@Published var stringTime = "00:00:00"
	@Published var isNearbyEnd = false
	@Published var isMeetingForceEnd = false
	@Published var futureDate = Date()
	@Published var dateTime = Date()
	@Published var isShowNearEndAlert = false
	@Published var isShowed = false
	
	@Published var isSwitched = true
	
	private var timer: Timer?
	
	let state = StateObservable.shared
	
	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		questionRepository: QuestionRepository = QuestionDefaultRepository(),
		userRepository: UsersRepository = UsersDefaultRepository(),
		twilioRepo: TwilioDataRepository = TwilioDataDefaultRepository(),
		meetRepository: MeetingsRepository = MeetingsDefaultRepository(),
		meeting: UserMeeting
	) {
		self.backToHome = backToHome
		self.backToRoot = backToRoot
		self.authRepository = authRepository
		self.questionRepository = questionRepository
		self.userRepository = userRepository
		self.twilioRepo = twilioRepo
		self.meetRepository = meetRepository
		self.meeting = meeting
		
		self.futureDate = meeting.endAt.orEmpty().toDate(format: .utcV2).orCurrentDate()
	}
	
	func routeToAfterCall() {
		let viewModel = AfterCallViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome)
		
		DispatchQueue.main.async {[weak self] in
			self?.route = .afterCall(viewModel: viewModel)
		}
	}
	
	func getRealTime() {
		let getting = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getTime), userInfo: nil, repeats: true)
		
		self.timer = getting
	}
	
	@objc func getTime() {
		
		let countDown = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: self.futureDate)
		guard let hours = countDown.hour else { return }
		guard let minutes = countDown.minute else { return }
		guard let seconds = countDown.second else { return }
		
		self.dateTime = Date()
		
		self.isNearbyEnd = dateTime <= (meeting.endAt?.toDate(format: .utcV2)).orCurrentDate().addingTimeInterval(-300)
		
		let startTime = (meeting.startAt?.toDate(format: .utcV2)).orCurrentDate()
		
		let countDownStart = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: startTime)
		guard let hoursStart = countDownStart.hour else { return }
		guard let minutesStart = countDownStart.minute else { return }
		guard let secondsStart = countDownStart.second else { return }
		
		if hours == 0 && minutes == 0 && seconds == 0 {
			self.checkMeetingEnd()
		}
		
		withAnimation {
			self.isShowNearEndAlert = minutes == 5 && seconds == 0
			
			self.isStarted = Date() >= ((meeting.startAt)?.toDate(format: .utcV2)).orCurrentDate() || meeting.startedAt != nil
		}
		
		if self.isStarted {
			self.stringTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
		} else {
			self.stringTime = String(format: "%02d:%02d:%02d", hoursStart, minutesStart, secondsStart)
		}
	}
	
	func checkMeetingEnd() {
		onStartFetch()
		
		self.stringTime = "00:00:00"
		
		meetRepository
			.providePostCheckMeetingEnd(meetingId: meeting.id)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.checkMeetingEnd()
							})
						} else {
							self?.isLoading = false
							self?.isError = true
							
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
				self.futureDate = (value.endAt?.toDate(format: .utcV2)).orCurrentDate()
				guard let isEnded = value.isEnd else { return }
				self.isMeetingForceEnd = isEnded
			}
			.store(in: &cancellables)
	}
	
	func totalParticipant(meeting: UserMeeting?) -> String {
		return "\(String((meeting?.bookings?.filter({ items in items.bookingPayment.paidAt != nil }).count).orZero()).toPriceFormat())/\(String((meeting?.slots).orZero()).toPriceFormat()) \(LocaleText.generalParticipant)"
	}
	
	func contentLabel(meeting: UserMeeting?) -> String {
		if (meeting?.slots).orZero() > 1 && !(meeting?.isLiveStreaming ?? false) {
			return NSLocalizedString("group", comment: "")
			
		} else if meeting?.isLiveStreaming ?? false {
			return LocaleText.liveStreamText
			
		} else {
			return NSLocalizedString("private", comment: "")
		}
	}
	
	func showingCloseAlert() {
		isShowingCloseAlert.toggle()
	}
	
	func onStartRefresh() {
		self.isRefreshFailed = false
		self.success = false
		self.error = nil
	}
	
	func onStartFetch() {
		DispatchQueue.main.async {[weak self] in
			self?.isError = false
			self?.isLoading = true
			self?.success = false
			self?.error = nil
		}
	}
	
	func deleteStream(completion: @escaping () -> Void) {
		onStartFetch()
		if state.twilioRole == "host" {
			twilioRepo.provideSyncDeleteStream(on: meeting.id)
				.sink { result in
					switch result {
					case .failure(let error):
						DispatchQueue.main.async {[weak self] in
							if error.statusCode.orZero() == 401 {
								self?.refreshToken(onComplete: {
									self?.deleteStream(completion: completion)
								})
							} else {
								self?.isLoading = false
								self?.isError = true
								
								self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
							}
						}
					case .finished:
						completion()
					}
				} receiveValue: { response in
					print(response)
				}
				.store(in: &cancellables)
		} else {
			self.isLoading = false
			self.isError = false
			completion()
		}
	}
	
	func getUsers() {
		
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
							
							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}
					
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						
					}
				}
			} receiveValue: { value in
				self.userData = value
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
						onComplete()
					}
					
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						self?.isRefreshFailed = true
						self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
					}
				}
			} receiveValue: { value in
				self.state.refreshToken = value.refreshToken
				self.state.accessToken = value.accessToken
			}
			.store(in: &cancellables)
		
	}
	
	func startPostQuestion() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoadingQuestion = true
			self?.isErrorQuestion = false
			self?.errorQuestion = nil
			self?.successQuestion = false
		}
	}
	
	func postQuestion(meetingId: String) {
		startPostQuestion()
		
		let params = QuestionParams(question: questionText, meetingId: meetingId, userId: (userData?.id).orEmpty())
		
		questionRepository.provideSendQuestion(params: params)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.postQuestion(meetingId: meetingId)
							})
						} else {
							self?.isLoadingQuestion = false
							self?.isErrorQuestion = true
							
							self?.errorQuestion = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}
					
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.successQuestion = true
						self?.isLoadingQuestion = false
						self?.isShowQuestionBox.toggle()
						self?.questionText = ""
					}
				}
			} receiveValue: { response in
				self.questionResponse = response
			}
			.store(in: &cancellables)
		
	}
	
	func getQuestion(meetingId: String) {
		
		questionRepository.provideGetQuestion(meetingId: meetingId)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getUsers ?? {})
						} else {
							self?.isError = true
							
							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}
					
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
					}
					
				}
			} receiveValue: { value in
				self.questionData = value
			}
			.store(in: &cancellables)
		
	}
	
	func putQuestion(questionId: Int, item: QuestionResponse, streamVM: StreamViewModel) {
		
		let parameter = QuestionBodyParam(isAnswered: !(item.isAnswered ?? true))
		
		questionRepository.providePutQuestion(questionId: questionId, params: parameter)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getUsers ?? {})
						} else {
							self?.isError = true
							
							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}
					
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						
					}
				}
			} receiveValue: { [self] value in
				questionResponse = value
				print("newres", value)
				getQuestion(meetingId: meeting.id)
				
			}
			.store(in: &cancellables)
	}
	
	func lockAllParticipantAudio(streamManager: StreamManager) {
		
		if isLockAllParticipantAudio {
			muteAllParticipant(streamManager: streamManager) {
				let message = RoomMessage(messageType: .mute, toParticipantIdentity: "all")
				streamManager.roomManager.localParticipant.sendMessage(message)
			}
		} else {
			muteAllParticipant(streamManager: streamManager, completion: {})
		}
	}
	
	func muteOnlyAllParticipant(streamManager: StreamManager) {
		self.showingMoreMenu = false
		let message = RoomMessage(messageType: .mute, toParticipantIdentity: "all")
		streamManager.roomManager.localParticipant.sendMessage(message)
		
		withAnimation {
			self.isMuteOnlyUser = true
		}
	}
	
	func muteAllParticipant(streamManager: StreamManager, completion: @escaping () -> Void) {
		let body = SyncMuteAllBody(roomSid: streamManager.roomSID.orEmpty(), lock: isLockAllParticipantAudio)
		
		twilioRepo.provideSyncMuteAllParticipant(on: meeting.id, target: body)
			.sink { result in
				switch result {
				case .finished:
					completion()
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.muteAllParticipant(streamManager: streamManager, completion: completion)
							})
						} else {
							self?.isError = true
							self?.isLockAllParticipantAudio = false
							
							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}
				}
			} receiveValue: { _ in
				
			}
			.store(in: &cancellables)
		
	}
}
