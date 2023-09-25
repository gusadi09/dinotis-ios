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
import DinotisData

final class PrivateVideoCallViewModel: ObservableObject {
	
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	
	private let getUserUseCase: GetUserUseCase
	private let authRepository: AuthenticationRepository
	private let getParticipantsUseCase: GetParticipantsUseCase
	private let sendReportUseCase: SendPanicReportUseCase
    private let getReasonUseCase: ReportReasonListUseCase
	private let twilioRepository: TwilioDataRepository
	private let singlePhotoUseCase: SinglePhotoUseCase
    private let checkMeetingEndUseCase: CheckEndedMeetingUseCase
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
	@Published var error: String?
	
	@Published var isRefreshFailed = false
	
	@Published var showingBottomSheet = false
	
	@Published var showingRepostModal = false
	
	@Published var report = ""
	
	@Published var userData: UserResponse?
	
	@Published var reason = [ReportReasonData]()
	@Published var participantData = [ParticipantData]()
	
	@Published var reportImage = UIImage()
	
	@Published var reasonData = [ReportReasonData]()
	
	@Published var isOther = false

	@Published var meeting: UserMeetingData

	@Published var futureDate = Date()
	@Published var isNearbyEnd = false
	@Published var isShowNearEndAlert = false
	@Published var isMeetingForceEnd = false
	@Published var isStarted = false
	@Published var stringTime = "00:00:00"
	private var timer: Timer?
	@Published var isShowedEnd = false
	
	init(
		meeting: UserMeetingData,
		backToHome: @escaping (() -> Void),
		getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        sendReportUseCase: SendPanicReportUseCase = SendPanicReportDefaultUseCase(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		getParticipantsUseCase: GetParticipantsUseCase = GetParticipantsDefaultUseCase(),
        singlePhotoUseCase: SinglePhotoUseCase = SinglePhotoDefaultUseCase(),
		twilioRepository: TwilioDataRepository = TwilioDataDefaultRepository(),
        getReasonUseCase: ReportReasonListUseCase = ReportReasonListDefaultUseCase(),
        checkMeetingEndUseCase: CheckEndedMeetingUseCase = CheckEndedMeetingDefaultUseCase()
	) {
		self.meeting = meeting
		self.backToHome = backToHome
		self.getUserUseCase = getUserUseCase
		self.sendReportUseCase = sendReportUseCase
		self.authRepository = authRepository
		self.getParticipantsUseCase = getParticipantsUseCase
		self.singlePhotoUseCase = singlePhotoUseCase
		self.twilioRepository = twilioRepository
        self.getReasonUseCase = getReasonUseCase
        self.checkMeetingEndUseCase = checkMeetingEndUseCase
	}
	
    func onStartFetch(sendReport: Bool) {
		DispatchQueue.main.async {[weak self] in
			self?.isError = false
			self?.isLoading = true
			self?.success = false
			self?.error = nil
            
            if sendReport {
                self?.isLoadingSend = true
                self?.isErrorSend = false
                self?.isSuccessSend = false
            }
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

		self.isNearbyEnd = Date() <= meeting.endAt.orCurrentDate().addingTimeInterval(-300)

		if hours == 0 && minutes == 0 && seconds == 0 {
            Task {
                await self.checkMeetingEnd()
            }
		}

		withAnimation {
			self.isShowNearEndAlert = minutes == 5 && seconds == 0 && hours == 0
		}
		
		self.stringTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
	}

	func endMeetingForce(streamManager: PrivateStreamManager) {
		if self.isStarted {
			streamManager.disconnect()
			self.routeToAfterCall()
		} else {
			self.routeToAfterCall()
		}
	}
    
    @MainActor
	func checkMeetingEnd() async {
        onStartFetch(sendReport: false)

		self.stringTime = "00:00:00"

        let result = await checkMeetingEndUseCase.execute(for: meeting.id.orEmpty())
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false

                self?.futureDate = success.endAt.orCurrentDate()
                guard let isEnded = success.isEnd else { return }
                self?.isMeetingForceEnd = isEnded
                self?.getRealTime()
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
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

	func getParticipant(by meetingId: String) async {
        onStartFetch(sendReport: false)

		let result = await getParticipantsUseCase.execute(by: meetingId)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.success = true
				self?.isLoading = false
				self?.participantData = success
			}
		case .failure(let failure):
			handleDefaultError(error: failure)
		}
	}

	func onGetParticipant(id: String) {
		Task {
			await self.getParticipant(by: id)
		}
	}
	
	func getUsers() async {
        onStartFetch(sendReport: false)
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.userData = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
	}
	
	func onStartRefresh() {
		self.isRefreshFailed = false
		self.isLoading = true
		self.success = false
		self.error = nil
	}
    
    func handleDefaultErrorUpload(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isLoadingSend = false

            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()

                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.isErrorSend = true
                }
            } else {
                self?.isErrorSend = true
                self?.error = error.localizedDescription
            }

        }
    }
	
	func uploadSingleImage() async {
        onStartFetch(sendReport: false)
        
        DispatchQueue.main.async {[weak self] in
            self?.isLoadingSend = true
            self?.isErrorSend = false
            self?.isSuccessSend = false
        }
		
        let result = await singlePhotoUseCase.execute(with: reportImage)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async {[weak self] in
                self?.isLoading = false
                self?.success = true
                self?.isLoadingSend = false
            }
            await self.sendReport(with: success)
        case .failure(let failure):
            handleDefaultErrorUpload(error: failure)
        }
	}

	func deleteStream(completion: @escaping () -> Void) {
        onStartFetch(sendReport: false)

		twilioRepository.providePrivateDeleteStream(on: meeting.id.orEmpty())
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
			} receiveValue: { response in
				completion()
			}
			.store(in: &cancellables)

	}
    
    func handleDefaultErrorReport(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isLoadingSend = false
            self?.isErrorSend = true

            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()

                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                }
            } else {
                self?.error = error.localizedDescription
            }

        }
    }
	
	func sendReport(with imgUrl: String) async {
		onStartFetch(sendReport: true)

		var strArr = [String]()

		for reason in reason {
			strArr.append(reason.name.orEmpty())
		}

		var stringReason = strArr.joined(separator: ", ")

		stringReason = isOther ? stringReason + ", \(report)" : stringReason

		let reportParams = ReportRequest(identity: (userData?.name).orEmpty(), reasons: stringReason, notes: imgUrl, room: meeting.id.orEmpty(), userId: (userData?.id).orEmpty(), meetingId: meeting.id.orEmpty())
        
        let result = await sendReportUseCase.execute(with: reportParams)
        
        switch result {
        case .success(_):
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
        case .failure(let failure):
            handleDefaultErrorReport(error: failure)
        }
	}
	
	func getReason() async {
        onStartFetch(sendReport: false)
        
        let result = await getReasonUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.reasonData = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
	}
	
	func isSelected(items: ReportReasonData) -> Bool {
		for item in reason where items.id == item.id {
			return true
		}
		
		return false
	}
	
	func screenShotMethod() {
        guard let window = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene else { return }
        guard let layer = window.windows.first else { return }
		let scale = UIScreen.main.scale
		UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
		
		guard let view = UIApplication.shared.windows.first?.rootViewController?.view else {return}
		view.drawHierarchy(in: layer.frame, afterScreenUpdates: false)
		guard let screenshot = UIGraphicsGetImageFromCurrentImageContext() else { return }
		
		self.reportImage = screenshot
	}
	
	func routeToAfterCall() {
		let viewModel = AfterCallViewModel(backToHome: self.backToHome)
		
		DispatchQueue.main.async {[weak self] in
			self?.route = .afterCall(viewModel: viewModel)
		}
	}
	
	func hudText() -> String {
		isSuccessSend ? LocaleText.successTitle : LocaleText.failedToReport
	}
}
