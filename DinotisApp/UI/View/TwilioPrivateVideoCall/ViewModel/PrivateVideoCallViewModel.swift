//
//  PrivateVideoCallViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 02/03/22.
//

import AVKit
import Combine
import DyteiOSCore
import DinotisDesignSystem
import DinotisData
import Foundation
import UIKit
import SwiftUI


final class PrivateVideoCallViewModel: ObservableObject {
	
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	
	private let getUserUseCase: GetUserUseCase
	private let authRepository: AuthenticationRepository
	private let getParticipantsUseCase: GetParticipantsUseCase
	private let sendReportUseCase: SendPanicReportUseCase
    private let getReasonUseCase: ReportReasonListUseCase
    private let addDyteParticipantUseCase: AddDyteParticipantUseCase
	private let singlePhotoUseCase: SinglePhotoUseCase
    private let checkMeetingEndUseCase: CheckEndedMeetingUseCase
	private var cancellables = Set<AnyCancellable>()
    
    var meetingInfo = DyteMeetingInfoV2(
        authToken: "",
        enableAudio: true,
        enableVideo: true,
        baseUrl: "https://api.cluster.dyte.in/v2"
    )
    
    @Published var dyteMeeting = DyteiOSClientBuilder().build()
    
    @Published var isConnecting = false
    @Published var isLeaving = false
    @Published var alert: AlertAttribute = .init()
    @Published var isShowAlert = false
    @Published var isInit = false
    @Published var participants = [DyteJoinedMeetingParticipant]()
    @Published var screenShareUser = [DyteJoinedMeetingParticipant]()
    @Published var screenShareId: DyteJoinedMeetingParticipant?
    @Published var pinned: DyteJoinedMeetingParticipant?
    @Published var host: DyteJoinedMeetingParticipant?
    @Published var lastActive: DyteJoinedMeetingParticipant?
    @Published var kicked: DyteJoinedMeetingParticipant?
    @Published var position: CameraPosition = .front
    @Published var isJoined = false
    @Published var localUserId = ""
    @Published var isDuplicate = false
    @Published var isCameraOn = true
    @Published var isAudioOn = true
    @Published var hasNewMessage = false
    @Published var isReceivedStageInvite = false
    @Published var hasNewParticipantRequest = false

	@Published var isLocalInSession = false
	@Published var isLocalAudioMuted = false
	@Published var isSwitchCam = true
    @Published var isShowUtilities = true
    
    @Published var participantPhotoUrl = ""
    @Published var userPhotoUrl = ""

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
	@Published var error: ErrorAlert?
	
	@Published var isRefreshFailed = false
	
	@Published var showingBottomSheet = false
	
	@Published var showingRepostModal = false
	
	@Published var report = ""
	
	@Published var userData: UserResponse?
	
	@Published var reason = [ReportReasonData]()
    @Published var participantData = [DinotisData.ParticipantData]()
	
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
        getReasonUseCase: ReportReasonListUseCase = ReportReasonListDefaultUseCase(),
        checkMeetingEndUseCase: CheckEndedMeetingUseCase = CheckEndedMeetingDefaultUseCase(),
        addDyteParticipantUseCase: AddDyteParticipantUseCase = AddDyteParticipantDefaultUseCase()
	) {
		self.meeting = meeting
		self.backToHome = backToHome
		self.getUserUseCase = getUserUseCase
		self.sendReportUseCase = sendReportUseCase
		self.authRepository = authRepository
		self.getParticipantsUseCase = getParticipantsUseCase
		self.singlePhotoUseCase = singlePhotoUseCase
        self.getReasonUseCase = getReasonUseCase
        self.checkMeetingEndUseCase = checkMeetingEndUseCase
        self.addDyteParticipantUseCase = addDyteParticipantUseCase
	}
    
    @MainActor
    func addParticipant() async {
        self.isConnecting = true
        self.isError = false
        self.error = nil
        
        let result = await addDyteParticipantUseCase.execute(for: meeting.id.orEmpty())
        
        switch result {
        case .success(let data):
            self.meetingInfo = DyteMeetingInfoV2(
                authToken: data.token.orEmpty(),
                enableAudio: true,
                enableVideo: true,
                baseUrl: "https://api.cluster.dyte.in/v2"
            )
            
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    func onAppear() {
        disableIdleTimer()
        getRealTime()
        forceAudioWhenMutedBySystem()
        
        futureDate = meeting.endAt.orCurrentDate()
        getRealTime()
        onGetReason()
        onGetUser()
        
        AppDelegate.orientationLock = .all
        Task {
            await addParticipant()
            dyteMeeting.addMeetingRoomEventsListener(meetingRoomEventsListener: self)
            dyteMeeting.addParticipantEventsListener(participantEventsListener: self)
            dyteMeeting.addSelfEventsListener(selfEventsListener: self)
            dyteMeeting.addParticipantEventsListener(participantEventsListener: self)
            dyteMeeting.addChatEventsListener(chatEventsListener: self)
            dyteMeeting.addRecordingEventsListener(recordingEventsListener: self)
            dyteMeeting.addWaitlistEventsListener(waitlistEventsListener: self)
            dyteMeeting.addStageEventsListener(stageEventsListener: self)
            dyteMeeting.doInit(dyteMeetingInfo_: meetingInfo)
        }
    }
    
    func onGetReason() {
        Task {
            await getReason()
        }
    }
    
    func onGetUser() {
        Task {
            await getUsers()
        }
    }
    
    func disableIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func forceAudioWhenMutedBySystem() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoChat, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    func onConnectionError() {
        // Handle connection error
        self.isConnecting = false
        self.isError = true
        self.error = .connection(LocalizableText.videoCallConnectionFailed)
        self.alert = .init(
            title: LocalizableText.attentionText,
            message: (self.error?.errorDescription).orEmpty(),
            primaryButton: .init(
                text: LocalizableText.videoCallLeaveRoom,
                action: {
                    self.leaveMeeting()
                }
            ),
            secondaryButton: .init(
                text: LocalizableText.videoCallRejoin,
                action: {
                    self.joinMeeting()
                }
            )
        )
        self.isShowAlert = true
    }
    
    func joinMeeting() {
        dyteMeeting.joinRoom()
    }
    
    func leaveMeeting() {
        dyteMeeting.leaveRoom()
    }
    
    func onJoinFailed() {
        // Handle join failed
        self.isConnecting = false
        self.isError = true
        self.error = .connection(LocalizableText.videoCallFailedJoin)
        self.alert = .init(
            title: LocalizableText.attentionText,
            message: (self.error?.errorDescription).orEmpty(),
            primaryButton: .init(
                text: LocalizableText.videoCallLeaveRoom,
                action: {
                    self.leaveMeeting()
                }
            ),
            secondaryButton: .init(
                text: LocalizableText.videoCallRejoin,
                action: {
                    self.joinMeeting()
                }
            )
        )
        self.isShowAlert = true
    }
    
    func madeToSpeaker() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .videoChat, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    func createInitial(_ name: String) -> String {
        return name.components(separatedBy: .whitespaces)
                    .filter { !$0.isEmpty }
                    .reduce("") { partialResult, word in
                        partialResult + String((word.first ?? Character("")).uppercased())
                }
    }
    
    func switchCamera() {
        DispatchQueue.main.async { [weak self] in
            if let devices = self?.dyteMeeting.localUser.getVideoDevices() {
                if let type = self?.dyteMeeting.localUser.getSelectedVideoDevice()?.type {
                    for device in devices {
                        if device.type != type {
                            self?.dyteMeeting.localUser.setVideoDevice(dyteVideoDevice: device)
                            if (self?.position ?? .front) == .front {
                                self?.position = .rear
                            } else {
                                self?.position = .front
                            }
                            
                            break
                        }
                    }
                }
            }
        }
    }
    
    func toggleCamera() {
        do {
            if dyteMeeting.localUser.videoEnabled {
                try dyteMeeting.localUser.disableVideo()
            } else {
                dyteMeeting.localUser.enableVideo()
            }
        } catch {
            print("error enable/disable camera")
        }
    }
    
    func toggleMicrophone() {
        do {
            if dyteMeeting.localUser.audioEnabled {
                try dyteMeeting.localUser.disableAudio()
            } else {
                dyteMeeting.localUser.enableAudio()
            }
        } catch {
            print("error enable/disable camera")
        }
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

	func endMeetingForce() {
		if self.isJoined {
			leaveMeeting()
		} else {
			self.routeToAfterCall()
		}
	}
    
    @MainActor
	func checkMeetingEnd() async {
        onStartFetch(sendReport: false)

		self.stringTime = "00:00:00"
        self.timer?.invalidate()

        let result = await checkMeetingEndUseCase.execute(for: meeting.id.orEmpty())
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false

                self?.futureDate = success.endAt.orCurrentDate()
                self?.stringTime = "00:00:00"
                guard let isEnded = success.isEnd else { return }
                self?.isMeetingForceEnd = isEnded
//                self?.getRealTime()
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
	}

	func handleDefaultError(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoading = false
            self?.isConnecting = false

			if let error = error as? ErrorResponse {
                self?.error = .api(error.message.orEmpty())
                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.isError = true
                }
                self?.alert = .init(
                    title: LocalizableText.attentionText,
                    message: (self?.error?.errorDescription).orEmpty(),
                    primaryButton: .init(text: LocalizableText.videoCallLeaveRoom, action: {})
                )
            } else {
                self?.isError = true
                self?.error = .api(error.localizedDescription)
                self?.alert = .init(
                    title: LocalizableText.attentionText,
                    message: (self?.error?.errorDescription).orEmpty(),
                    primaryButton: .init(text: LocalizableText.videoCallLeaveRoom, action: {})
                )
            }
            
            self?.isShowAlert = true
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
                self?.userPhotoUrl = success.profilePhoto ?? ""
                self?.participantPhotoUrl = success.id == self?.meeting.participantDetails?.first?.id ? self?.meeting.user?.profilePhoto ?? "" : self?.participantPhotoUrl ?? ""
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
            self?.isConnecting = false

            if let error = error as? ErrorResponse {
                self?.error = .api(error.message.orEmpty())
                
                self?.alert = .init(
                    title: LocalizableText.attentionText,
                    message: (self?.error?.errorDescription).orEmpty(),
                    primaryButton: .init(text: LocalizableText.videoCallLeaveRoom, action: {})
                )

                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.isErrorSend = true
                }
            } else {
                self?.isErrorSend = true
                self?.error = .api(error.localizedDescription)
                self?.alert = .init(
                    title: LocalizableText.attentionText,
                    message: (self?.error?.errorDescription).orEmpty(),
                    primaryButton: .init(text: LocalizableText.videoCallLeaveRoom, action: {})
                )
            }

            self?.isShowAlert = true
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
    
    func handleDefaultErrorReport(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isLoadingSend = false
            self?.isErrorSend = true
            self?.isConnecting = false

            if let error = error as? ErrorResponse {
                self?.error = .api(error.message.orEmpty())
                
                self?.alert = .init(
                    title: LocalizableText.attentionText,
                    message: (self?.error?.errorDescription).orEmpty(),
                    primaryButton: .init(text: LocalizableText.videoCallLeaveRoom, action: {})
                )

                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.isError = true
                }
            } else {
                self?.error = .api(error.localizedDescription)
                self?.alert = .init(
                    title: LocalizableText.attentionText,
                    message: (self?.error?.errorDescription).orEmpty(),
                    primaryButton: .init(text: LocalizableText.videoCallLeaveRoom, action: {})
                )
            }

            self?.isShowAlert = true
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
    
    func userType(preset: String) -> String {
        if preset == PresetConstant.admin.value {
            return "(Admin)"
        } else if preset == PresetConstant.host.value {
            return "(Host)"
        } else if preset == PresetConstant.coHost.value {
            return "(Co-Host)"
        } else {
            return ""
        }
    }
}

extension PrivateVideoCallViewModel: DyteMeetingRoomEventsListener {
    func onActiveTabUpdate(id: String, tabType: ActiveTabType) {
        
    }
    
    func onConnectedToMeetingRoom() {
        self.isConnecting = false
    }
    
    func onConnectingToMeetingRoom() {
        self.isConnecting = true
    }
    
    func onDisconnectedFromMeetingRoom() {
        if !isLeaving {
            self.isError = true
            self.error = .disconnected
            self.alert = .init(
                title: LocalizableText.attentionText,
                message: (self.error?.errorDescription).orEmpty(),
                primaryButton: .init(
                    text: LocalizableText.videoCallLeaveRoom,
                    action: {
                        self.routeToAfterCall()
                    }
                )
            )
            self.isShowAlert = true
        }
    }
    
    func onMeetingRoomConnectionFailed() {
        self.onConnectionError()
    }
    
    func onMeetingInitCompleted() {
        joinMeeting()
        
        self.isInit = true
    }
    
    
    func onMeetingInitFailed(exception: KotlinException) {
        self.isInit = false
        self.isError = true
        self.error = .connection(exception.description())
        self.alert = .init(
            title: LocalizableText.attentionText,
            message: (self.error?.errorDescription).orEmpty(),
            primaryButton: .init(
                text: LocalizableText.videoCallLeaveRoom,
                action: {
                    self.leaveMeeting()
                }
            ),
            secondaryButton: .init(
                text: LocalizableText.videoCallRejoin,
                action: {
                    self.joinMeeting()
                }
            )
        )
        self.isShowAlert = true
    }
    
    func onMeetingInitStarted() {
        self.isConnecting = true
    }
    
    func onMeetingRoomConnectionError(errorMessage: String) {
        self.isConnecting = false
        self.isError = true
        self.error = .connection(errorMessage)
        self.alert = .init(
            title: LocalizableText.attentionText,
            message: (self.error?.errorDescription).orEmpty(),
            primaryButton: .init(
                text: LocalizableText.videoCallLeaveRoom,
                action: {
                    self.leaveMeeting()
                }
            ),
            secondaryButton: .init(
                text: LocalizableText.videoCallRejoin,
                action: {
                    self.joinMeeting()
                }
            )
        )
        self.isShowAlert = true
    }
    
    func onMeetingRoomDisconnected() {
        
    }
    
    func onMeetingRoomJoinCompleted() {
        self.participants = dyteMeeting.participants.active
        self.screenShareUser = dyteMeeting.participants.screenShares
        self.screenShareId = dyteMeeting.participants.screenShares.first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.host = self?.dyteMeeting.participants.joined.first(where: { item in
                item.presetName.contains(PresetConstant.host.value)
            })
            self?.lastActive = self?.dyteMeeting.participants.activeSpeaker
        }
        
        withAnimation {
            self.isJoined = true
        }
        self.isConnecting = false
        
        self.pinned = dyteMeeting.participants.pinned
        self.localUserId = dyteMeeting.localUser.userId
        self.dyteMeeting.participants.broadcastMessage(type: "duplicate-check", payload: [
            "peerId" : self.dyteMeeting.localUser.id,
            "userId" : self.dyteMeeting.localUser.userId
        ])
    }
    
    func onMeetingRoomJoinFailed(exception: KotlinException) {
        self.onJoinFailed()
    }
    
    func onMeetingRoomJoinStarted() {
        self.isConnecting = true
    }
    
    func onMeetingRoomLeaveCompleted() {
        self.isConnecting = false
        self.isInit = false
        self.isJoined = false
        self.routeToAfterCall()
    }
    
    func onMeetingRoomLeaveStarted() {
        self.isLeaving = true
        self.isConnecting = true
    }
    
    func onMeetingRoomReconnectionFailed() {
        self.onConnectionError()
    }
    
    func onReconnectedToMeetingRoom() {
        self.isConnecting = false
    }
    
    func onReconnectingToMeetingRoom() {
        self.isConnecting = true
    }
    
}

extension PrivateVideoCallViewModel: DyteParticipantEventsListener {
    func onAllParticipantsUpdated(allParticipants: [DyteParticipant]) {
        self.participants.removeAll()
        self.participants = dyteMeeting.participants.active
    }
    
    func onScreenShareEnded(participant: DyteJoinedMeetingParticipant) {
        if dyteMeeting.participants.screenShares.count != screenShareUser.count {
            self.screenShareUser = dyteMeeting.participants.screenShares
        }
        if self.screenShareId == nil || self.dyteMeeting.participants.screenShares.count <= 1 {
            self.screenShareId = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                self.screenShareId = self.dyteMeeting.participants.screenShares.last
            }
        }
    }
    
    func onScreenShareStarted(participant: DyteJoinedMeetingParticipant) {
        if dyteMeeting.participants.screenShares.count != screenShareUser.count {
            self.screenShareUser = dyteMeeting.participants.screenShares
        }
        if self.screenShareId == nil || self.dyteMeeting.participants.screenShares.count <= 1 {
            self.screenShareId = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                self.screenShareId = self.dyteMeeting.participants.screenShares.first
            }
        }
    }
    
    func onActiveSpeakerChanged(participant: DyteJoinedMeetingParticipant) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.host = self?.dyteMeeting.participants.joined.first(where: { item in
                item.presetName.contains(PresetConstant.host.value)
            })
            self?.lastActive = self?.dyteMeeting.participants.activeSpeaker
        }
    }
    
    func onParticipantJoin(participant: DyteJoinedMeetingParticipant) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.host = self?.dyteMeeting.participants.joined.first(where: { item in
                item.presetName.contains(PresetConstant.host.value)
            })
            self?.lastActive = self?.dyteMeeting.participants.activeSpeaker
        }
        self.participants.removeAll()
        self.participants = dyteMeeting.participants.active
    }
    
    func onParticipantLeave(participant: DyteJoinedMeetingParticipant) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.host = self?.dyteMeeting.participants.joined.first(where: { item in
                item.presetName.contains(PresetConstant.host.value)
            })
            self?.lastActive = self?.dyteMeeting.participants.activeSpeaker
        }
        self.participants.removeAll()
        self.participants = dyteMeeting.participants.active
    }
    
    func onParticipantPinned(participant: DyteJoinedMeetingParticipant) {
        self.pinned = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.pinned = participant
        }
        
        self.participants.removeAll()
        self.participants = dyteMeeting.participants.active
    }
    
    func onParticipantUnpinned(participant: DyteJoinedMeetingParticipant) {
        self.pinned = nil
        
        self.participants.removeAll()
        self.participants = dyteMeeting.participants.active
    }
    
    func onActiveParticipantsChanged(active: [DyteJoinedMeetingParticipant]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.host = self?.dyteMeeting.participants.joined.first(where: { item in
                item.presetName.contains(PresetConstant.host.value)
            })
            self?.lastActive = self?.dyteMeeting.participants.activeSpeaker
        }
        self.participants.removeAll()
        self.participants = dyteMeeting.participants.active
    }
    
    func onActiveSpeakerChanged(participant: DyteMeetingParticipant) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.host = self?.dyteMeeting.participants.joined.first(where: { item in
                item.presetName.contains(PresetConstant.host.value)
            })
            self?.lastActive = self?.dyteMeeting.participants.activeSpeaker
        }
    }
    
    func onAudioUpdate(audioEnabled: Bool, participant: DyteMeetingParticipant) {
        self.participants.removeAll()
        self.participants = dyteMeeting.participants.active
    }
    
    func onNoActiveSpeaker() {
        
    }
    
    func onScreenSharesUpdated() {
        if dyteMeeting.participants.screenShares.count != screenShareUser.count {
            self.screenShareUser = dyteMeeting.participants.screenShares
        }
    }
    
    func onUpdate(participants: DyteRoomParticipants) {
        self.participants.removeAll()
        self.participants = dyteMeeting.participants.active
    }
    
    func onVideoUpdate(videoEnabled: Bool, participant: DyteMeetingParticipant) {
        self.participants.removeAll()
        self.participants = dyteMeeting.participants.active
    }
    
}

extension PrivateVideoCallViewModel: DyteSelfEventsListener {
    func onVideoDeviceChanged(videoDevice: DyteVideoDevice) {
        
    }
    
    func onRoomMessage(type: String, payload: [String : Any]) {
        
        self.isDuplicate = type.contains("duplicate-check") && !String(describing: payload["peerId"]).contains(self.dyteMeeting.localUser.id) && String(describing: payload["userId"]).contains(self.dyteMeeting.localUser.userId)
    }
    
    func onStageStatusUpdated(stageStatus: StageStatus) {
       
    }
    
    func onAudioDevicesUpdated() {
        
    }
    
    func onAudioUpdate(audioEnabled: Bool) {
        isAudioOn = audioEnabled
    }
    
    func onMeetingRoomJoinedWithoutCameraPermission() {
        
    }
    
    func onMeetingRoomJoinedWithoutMicPermission() {
        
    }
    
    func onProximityChanged(isNear: Bool) {
        
    }
    
    func onRemovedFromMeeting() {
        self.isLeaving = true
        self.error = nil
        self.isError = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.alert = .init(
                title: LocalizableText.videoCallKickedAlertTitle,
                primaryButton: .init(
                    text: LocalizableText.understoodText,
                    action: {
                        self.isConnecting = false
                        self.routeToAfterCall()
                    }
                )
            )
            self.isShowAlert = true
        }
    }
    
    func onStoppedPresenting() {
        
    }
    
    func onUpdate(participant_ participant: DyteSelfParticipant) {
        
    }
    
    func onVideoUpdate(videoEnabled: Bool) {
        isCameraOn = videoEnabled
    }
    
    func onWaitListStatusUpdate(waitListStatus: WaitListStatus) {
        if waitListStatus == .waiting {
            self.isConnecting = false
        }
    }
    
}

extension PrivateVideoCallViewModel: DyteChatEventsListener {
    func onChatUpdates(messages: [DyteChatMessage]) {
        
    }
    
    func onNewChatMessage(message: DyteChatMessage) {
        hasNewMessage = true
    }
    
}

extension PrivateVideoCallViewModel: DyteRecordingEventsListener {
    func onMeetingRecordingPauseError(e: KotlinException) {
        
    }
    
    func onMeetingRecordingResumeError(e: KotlinException) {
        
    }
    
    func onMeetingRecordingEnded() {
        
    }
    
    func onMeetingRecordingStarted() {
        
    }
    
    func onMeetingRecordingStateUpdated(state: DyteRecordingState) {
        
    }
    
    func onMeetingRecordingStopError(e: KotlinException) {
        
    }
    
}

extension PrivateVideoCallViewModel: DyteWaitlistEventsListener {
    func onWaitListParticipantAccepted(participant: DyteWaitlistedParticipant) {
        
    }
    
    func onWaitListParticipantClosed(participant: DyteWaitlistedParticipant) {
        
    }
    
    func onWaitListParticipantJoined(participant: DyteWaitlistedParticipant) {
        self.hasNewParticipantRequest = true
    }
    
    func onWaitListParticipantRejected(participant: DyteWaitlistedParticipant) {
        
    }
    
}

extension PrivateVideoCallViewModel: DyteStageEventListener {
    func onParticipantStartedPresenting(participant: DyteJoinedMeetingParticipant) {
        
    }
    
    func onParticipantStoppedPresenting(participant: DyteJoinedMeetingParticipant) {
        
    }
    
    func onParticipantRemovedFromStage(participant: DyteJoinedMeetingParticipant) {
        if participant.id == dyteMeeting.localUser.id {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.alert = .init(
                    title: LocalizableText.videoCallMoveToViewerAlertTitle,
                    primaryButton: .init(
                        text: LocalizableText.understoodText,
                        action: { self.alert = .init() }
                    )
                )
                self.isShowAlert = true
            }
        }
    }
    
    func onAddedToStage() {
        self.isReceivedStageInvite = false
    }
    
    func onPresentRequestAccepted(participant: DyteJoinedMeetingParticipant) {
        
    }
    
    func onPresentRequestAdded(participant: DyteJoinedMeetingParticipant) {
        self.hasNewParticipantRequest = true
    }
    
    func onPresentRequestClosed(participant: DyteJoinedMeetingParticipant) {
        
    }
    
    func onPresentRequestReceived() {
        
        self.dyteMeeting.localUser.enableVideo()
        do {
            try self.dyteMeeting.localUser.disableAudio()
            try self.dyteMeeting.localUser.disableVideo()
        } catch {
            print("error preview")
        }
        
        self.isReceivedStageInvite = true
    }
    
    func onPresentRequestRejected(participant: DyteJoinedMeetingParticipant) {
        
    }
    
    func onPresentRequestWithdrawn(participant: DyteJoinedMeetingParticipant) {
        
    }
    
    func onRemovedFromStage() {
        
    }
    
    func onStageRequestsUpdated(accessRequests: [DyteJoinedMeetingParticipant]) {

    }
}
