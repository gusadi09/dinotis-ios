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
import DinotisData

final class TwilioLiveStreamViewModel: ObservableObject {
	
//	private let questionRepository: QuestionRepository
	private let authRepository: AuthenticationRepository
	private let meetRepository: MeetingsRepository
	private let getUserUseCase: GetUserUseCase
	private let twilioRepo: TwilioDataRepository
	private var cancellables = Set<AnyCancellable>()
    
    private let getQuestionUseCase: GetQuestionUseCase
    private let putQuestionUseCase: PutQuestionUseCase
    private let sendQuestionUseCase: SendQuestionUseCase
	
	var backToRoot: (() -> Void)
	var backToHome: (() -> Void)
    
    @Published var questionData = [QuestionData]()
	@Published var route: HomeRouting? = nil
	@Published var isShowingToolbar = true
	
	@Published var meeting: UserMeetingData
	@Published var userData: UserResponse?
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
	@Published var errorQuestion: String?
	@Published var successQuestion: Bool = false
	@Published var questionResponse: QuestionData?
	
	@Published var isRefreshFailed = false
	@Published var isLoading: Bool = false
	@Published var error: String?
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
		getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
		twilioRepo: TwilioDataRepository = TwilioDataDefaultRepository(),
		meetRepository: MeetingsRepository = MeetingsDefaultRepository(),
		meeting: UserMeetingData,
        getQuestionUseCase: GetQuestionUseCase = GetQuestionDefaultUseCase(),
        putQuestionUseCase: PutQuestionUseCase = PutQuestionDefaultUseCase(),
        sendQuestionUseCase: SendQuestionUseCase = SendQuestionDefaultUseCase()
	) {
		self.backToHome = backToHome
		self.backToRoot = backToRoot
		self.authRepository = authRepository
		self.getUserUseCase = getUserUseCase
		self.twilioRepo = twilioRepo
		self.meetRepository = meetRepository
		self.meeting = meeting
        self.getQuestionUseCase = getQuestionUseCase
        self.putQuestionUseCase = putQuestionUseCase
        self.sendQuestionUseCase = sendQuestionUseCase
		self.futureDate = meeting.endAt.orCurrentDate()
	}
    
    func qnaFiltered() -> [QuestionData] {
        return questionData.filter({ item in
            QnASegment == 0 ? !(item.isAnswered ?? false) : (item.isAnswered ?? false)
        })
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
		
		self.isNearbyEnd = dateTime <= meeting.endAt.orCurrentDate().addingTimeInterval(-300)
		
		if hours == 0 && minutes == 0 && seconds == 0 {
			self.checkMeetingEnd()
		}
		
		withAnimation {
			self.isShowNearEndAlert = minutes == 5 && seconds == 0 && hours == 0
		}

		self.stringTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
	}
	
	func checkMeetingEnd() {
		onStartFetch()
		
		self.stringTime = "00:00:00"
		
		meetRepository
			.providePostCheckMeetingEnd(meetingId: meeting.id.orEmpty())
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							
						} else {
							self?.isLoading = false
							self?.isError = true
							
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
				self.futureDate = value.endAt.orCurrentDate()
				guard let isEnded = value.isEnd else { return }
				self.isMeetingForceEnd = isEnded
			}
			.store(in: &cancellables)
	}
	
	func totalParticipant(meeting: UserMeetingData?) -> String {
		return "\(String((meeting?.participants).orZero()).toPriceFormat())/\(String((meeting?.slots).orZero()).toPriceFormat()) \(LocaleText.generalParticipant)"
	}
	
	func contentLabel(meeting: UserMeetingData?) -> String {
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
			twilioRepo.provideSyncDeleteStream(on: meeting.id.orEmpty())
				.sink { result in
					switch result {
					case .failure(let error):
						DispatchQueue.main.async {[weak self] in
							if error.statusCode.orZero() == 401 {
								
							} else {
								self?.isLoading = false
								self?.isError = true
								
								self?.error = error.message.orEmpty()
							}
						}
					case .finished:
						completion()
					}
				} receiveValue: { _ in

				}
				.store(in: &cancellables)
		} else {
			self.isLoading = false
			self.isError = false
			completion()
		}
	}
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false

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
    
    func getUsers() async {
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.userData = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    @MainActor
    func getQuestion() async {
        self.isError = false
        self.error = nil

        let result = await getQuestionUseCase.execute(for: meeting.id.orEmpty())

        switch result {
        case .success(let data):
            self.success = true
            self.questionData = data
        case .failure(let error):
            handleDefaultError(error: error)
        }

    }
    
    @MainActor
    func putQuestion(item: QuestionData) async {
        self.isError = false
        self.error = nil

        let parameter = AnsweredRequest(isAnswered: !(item.isAnswered ?? false))
        let result = await putQuestionUseCase.execute(questionId: item.id.orZero(), params: parameter)
        
        switch result {
        case .success(let data):
            self.success = true
            self.questionResponse = data
            await self.getQuestion()
            
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    @MainActor
    func sendQuestion(meetingId: String) async {
        self.isLoadingQuestion = true
        self.isError = false
        self.error = nil
        self.successQuestion = false

        let params = QuestionRequest(question: questionText, meetingId: meetingId, userId: StateObservable.shared.userId)
        let result = await sendQuestionUseCase.execute(params: params)

        switch result {
        case .success(let data):
            
            self.successQuestion = true
            self.isLoadingQuestion = false
            self.isShowQuestionBox.toggle()
            self.questionText = ""
            self.questionResponse = data
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
	
//	func startPostQuestion() {
//		DispatchQueue.main.async {[weak self] in
//			self?.isLoadingQuestion = true
//			self?.isErrorQuestion = false
//			self?.errorQuestion = nil
//			self?.successQuestion = false
//		}
//	}
//
//	func postQuestion(meetingId: String) {
//		startPostQuestion()
//
//		let params = QuestionParams(question: questionText, meetingId: meetingId, userId: (userData?.id).orEmpty())
//
//		questionRepository.provideSendQuestion(params: params)
//			.sink { result in
//				switch result {
//				case .failure(let error):
//					DispatchQueue.main.async {[weak self] in
//						if error.statusCode.orZero() == 401 {
//
//						} else {
//							self?.isLoadingQuestion = false
//							self?.isErrorQuestion = true
//
//							self?.errorQuestion = error.message.orEmpty()
//						}
//					}
//
//				case .finished:
//					DispatchQueue.main.async { [weak self] in
//						self?.successQuestion = true
//						self?.isLoadingQuestion = false
//						self?.isShowQuestionBox.toggle()
//						self?.questionText = ""
//					}
//				}
//			} receiveValue: { response in
//				self.questionResponse = response
//			}
//			.store(in: &cancellables)
//
//	}
//
//	func getQuestion(meetingId: String) {
//
//		questionRepository.provideGetQuestion(meetingId: meetingId)
//			.sink { result in
//				switch result {
//				case .failure(let error):
//					DispatchQueue.main.async {[weak self] in
//						if error.statusCode.orZero() == 401 {
//
//						} else {
//							self?.isError = true
//
//							self?.error = error.message.orEmpty()
//						}
//					}
//
//				case .finished:
//					DispatchQueue.main.async { [weak self] in
//						self?.success = true
//					}
//
//				}
//			} receiveValue: { value in
//				self.questionData = value
//			}
//			.store(in: &cancellables)
//
//	}
//
//	func putQuestion(questionId: Int, item: QuestionResponse, streamVM: StreamViewModel) {
//
//		let parameter = QuestionBodyParam(isAnswered: !(item.isAnswered ?? true))
//
//		questionRepository.providePutQuestion(questionId: questionId, params: parameter)
//			.sink { result in
//				switch result {
//				case .failure(let error):
//					DispatchQueue.main.async {[weak self] in
//						if error.statusCode.orZero() == 401 {
//
//						} else {
//							self?.isError = true
//
//							self?.error = error.message.orEmpty()
//						}
//					}
//
//				case .finished:
//					DispatchQueue.main.async { [weak self] in
//						self?.success = true
//
//					}
//				}
//			} receiveValue: { [self] value in
//				questionResponse = value
//				getQuestion(meetingId: meeting.id.orEmpty())
//
//			}
//			.store(in: &cancellables)
//	}
	
	func lockAllParticipantAudio(streamManager: StreamManager) {
		
		if isLockAllParticipantAudio {
			muteAllParticipant(streamManager: streamManager) {
				let message = RoomMessage(messageType: .mute, toParticipantIdentity: "all")
				streamManager.roomManager?.localParticipant.sendMessage(message)
			}
		} else {
			muteAllParticipant(streamManager: streamManager, completion: {})
		}
	}
	
	func muteOnlyAllParticipant(streamManager: StreamManager) {
		self.showingMoreMenu = false
		let message = RoomMessage(messageType: .mute, toParticipantIdentity: "all")
		streamManager.roomManager?.localParticipant.sendMessage(message)
		
		withAnimation {
			self.isMuteOnlyUser = true
		}
	}
	
	func muteAllParticipant(streamManager: StreamManager, completion: @escaping () -> Void) {
		let body = SyncMuteAllBody(roomSid: streamManager.roomSID.orEmpty(), lock: isLockAllParticipantAudio)
		
		twilioRepo.provideSyncMuteAllParticipant(on: meeting.id.orEmpty(), target: body)
			.sink { result in
				switch result {
				case .finished:
					completion()
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							
						} else {
							self?.isError = true
							self?.isLockAllParticipantAudio = false
							
							self?.error = error.message.orEmpty()
						}
					}
				}
			} receiveValue: { _ in
				
			}
			.store(in: &cancellables)
		
	}
}
