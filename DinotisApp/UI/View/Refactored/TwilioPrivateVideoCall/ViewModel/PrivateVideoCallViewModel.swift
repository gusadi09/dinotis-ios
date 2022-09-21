//
//  PrivateVideoCallViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 02/03/22.
//

import Foundation
import UIKit
import Combine
import SwiftUI

final class PrivateVideoCallViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	
	private let usersRepository: UsersRepository
	private let authRepository: AuthenticationRepository
	private let bookRepository: BookingsRepository
	private let reportRepository: ReportRepository
	private let meetRepository: MeetingsRepository
	private let twilioRepository: TwilioDataRepository
	private let uploadService: UploadService
	private var cancellables = Set<AnyCancellable>()

	@Published var isLocalInSession = false
	@Published var isLocalAudioMuted = false
	@Published var isSwitchCam = true

	@Published var isRemoteAudioMuted = false

	@Published var isSwitchCanvas = false

	@Published var isRemoteInSession = false
	@Published var isRemoteVideoMuted = false

	@Published var remoteImage: String?
	@Published var remoteName: String?

	@Published var connectionLost = false

	@Published var rejoined = false

	@Published var remoteText = NSLocalizedString("waiting_text", comment: "")

	@Published var isShowEnd = false

	@Published var dragOffset = CGPoint(x: 0, y: 0)
	
	@Published var route: HomeRouting?
	
	@Published var isLoading = false
	@Published var isLoadingSend = false
	@Published var isErrorSend = false
	@Published var isSuccessSend = false
	@Published var isError = false
	@Published var success = false
	@Published var error: HMError?
	
	@Published var isRefreshFailed = false
	
	@Published var showingBottomSheet = false
	
	@Published var showingRepostModal = false
	
	@Published var report = ""
	
	@Published var userData: Users?
	
	@Published var reason = [ReportReasonData]()
	@Published var participantData = [ParticipantData]()
	
	@Published var reportImage = UIImage()
	
	@Published var reasonData = [ReportReasonData]()
	
	@Published var isOther = false

	@Published var meeting: UserMeeting

	@Published var futureDate = Date()
	@Published var isNearbyEnd = false
	@Published var isShowNearEndAlert = false
	@Published var isMeetingForceEnd = false
	@Published var isStarted = false
	@Published var stringTime = "00:00:00"
	private var timer: Timer?
	@Published var isShowedEnd = false
	
	init(
		meeting: UserMeeting,
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		meetRepository: MeetingsRepository = MeetingsDefaultRepository(),
		userRepository: UsersRepository = UsersDefaultRepository(),
		reportRepository: ReportRepository = ReportDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		bookRepository: BookingsRepository = BookingsDefaultRepository(),
		uploadService: UploadService = UploadService(),
		twilioRepository: TwilioDataRepository = TwilioDataDefaultRepository()
	) {
		self.meeting = meeting
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.meetRepository = meetRepository
		self.usersRepository = userRepository
		self.reportRepository = reportRepository
		self.authRepository = authRepository
		self.bookRepository = bookRepository
		self.uploadService = uploadService
		self.twilioRepository = twilioRepository
	}
	
	func onStartFetch() {
		DispatchQueue.main.async {[weak self] in
			self?.isError = false
			self?.isLoading = true
			self?.success = false
			self?.error = nil
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

		self.isNearbyEnd = Date() <= (meeting.endAt?.toDate(format: .utcV2)).orCurrentDate().addingTimeInterval(-300)

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

	func endMeetingForce(streamManager: PrivateStreamManager) {
		if self.isStarted {
			streamManager.disconnect()
			self.routeToAfterCall()
		} else {
			self.routeToAfterCall()
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

	func getParticipant(by meetingId: String) {
		onStartFetch()

		bookRepository
			.provideGetParticipant(by: meetingId)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken {
								self?.getParticipant(by: meetingId)
							}
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
				self.participantData = value
			}
			.store(in: &cancellables)
	}
	
	func getUsers() {
		onStartFetch()
		
		usersRepository
			.provideGetUsers()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getUsers ?? {})
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
				self.userData = value
			}
			.store(in: &cancellables)
		
	}
	
	func onStartRefresh() {
		self.isRefreshFailed = false
		self.isLoading = true
		self.success = false
		self.error = nil
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
	
	func uploadSingleImage() {
		onStartFetch()
		self.isLoadingSend = true
		isErrorSend = false
		isSuccessSend = false
		
		uploadService.uploadSingle(image: reportImage) { response, error in
			if error == nil {
				self.isLoading = false
				self.success = true
				self.isLoadingSend = false
				self.sendReport(with: (response?.url).orEmpty())
			} else {
				self.isErrorSend = true
				self.isLoading = false
				self.isLoadingSend = false
				self.error = .serverError(code: (error?.statusCode).orZero(), message: (error?.message).orEmpty())
			}
		}
	}

	func deleteStream(completion: @escaping () -> Void) {
		onStartFetch()

		twilioRepository.providePrivateDeleteStream(on: meeting.id)
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
					DispatchQueue.main.async { [weak self] in
						self?.success = true

						self?.isLoading = false

					}
				}
			} receiveValue: { response in
				completion()
			}
			.store(in: &cancellables)

	}
	
	func sendReport(with imgUrl: String) {
		onStartFetch()
		self.isLoadingSend = true
		isErrorSend = false
		isSuccessSend = false

		var strArr = [String]()

		for reason in reason {
			strArr.append(reason.name.orEmpty())
		}

		var stringReason = strArr.joined(separator: ", ")

		stringReason = isOther ? stringReason + ", \(report)" : stringReason

		let reportParams = ReportParams(identity: (userData?.name).orEmpty(), reasons: stringReason, notes: imgUrl, room: meeting.id, userId: (userData?.id).orEmpty(), meetingId: meeting.id)

		reportRepository
			.provideSendPanicReport(with: reportParams)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getUsers ?? {})
						} else {
							self?.isLoading = false
							self?.isLoadingSend = false
							self?.isErrorSend = true

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						withAnimation {
							self?.isSuccessSend = true
						}

						self?.isLoading = false
						self?.isLoadingSend = false

						self?.reason = []
						self?.reportImage = UIImage()
						self?.report = ""
						self?.isOther = false

					}
				}
			} receiveValue: { _ in

			}
			.store(in: &cancellables)
		
	}
	
	func getReason() {
		onStartFetch()
		
		reportRepository
			.provideGetReportReason()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getUsers ?? {})
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
				self.reasonData = value
			}
			.store(in: &cancellables)
		
	}
	
	func isSelected(items: ReportReasonData) -> Bool {
		for item in reason where items.id == item.id {
			return true
		}
		
		return false
	}
	
	func screenShotMethod() {
		let layer = UIApplication.shared.windows.first!.layer
		let scale = UIScreen.main.scale
		UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
		
		guard let view = UIApplication.shared.windows.first!.rootViewController?.view else {return}
		view.drawHierarchy(in: layer.frame, afterScreenUpdates: false)
		guard let screenshot = UIGraphicsGetImageFromCurrentImageContext() else { return }
		
		self.reportImage = screenshot
	}
	
	func routeToAfterCall() {
		let viewModel = AfterCallViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome)
		
		DispatchQueue.main.async {[weak self] in
			self?.route = .afterCall(viewModel: viewModel)
		}
	}
	
	func hudText() -> String {
		isSuccessSend ? LocaleText.successTitle : LocaleText.failedToReport
	}
}
