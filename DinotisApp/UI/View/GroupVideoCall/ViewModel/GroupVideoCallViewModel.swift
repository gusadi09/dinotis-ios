//
//  GroupVideoCallViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/23.
//

import AVFoundation
import Combine
import DyteiOSCore
import UIKit
import SwiftUI
import DinotisDesignSystem
import DinotisData
import FirebaseDatabase

struct TabBarItem: Identifiable {
    let id: Int
    let title: String
}

enum CameraPosition {
    case front
    case rear
}

enum PresetConstant {
    case host
    case coHost
    case admin
    case viewer
    
    var value: String {
        switch self {
        case .host:
            return "dinotis_host"
        case .coHost:
            return "dinotis_cohost"
        case .admin:
            return "dinotis_admin"
        case .viewer:
            return "dinotis_viewer"
        }
    }
}

enum ErrorAlert {
    case disconnected
    case defaultError(String)
    case connection(String)
    case api(String)
    
    var errorDescription: String {
        switch self {
        case .disconnected:
            return LocalizableText.videoCallDisconnected
        case .defaultError(let message):
            return message
        case .connection(let message):
            return message
        case .api(let message):
            return message
        }
    }
}

final class GroupVideoCallViewModel: ObservableObject {
    private var timer: Timer?
    var backToHome: () -> Void
    var backToScheduleDetail: () -> Void
    
    private let meetRepository: MeetingsRepository
    
    private let addDyteParticipantUseCase: AddDyteParticipantUseCase
    private var cancellables = Set<AnyCancellable>()
    
    
    private let getQuestionUseCase: GetQuestionUseCase
    private let putQuestionUseCase: PutQuestionUseCase
    private let sendQuestionUseCase: SendQuestionUseCase
    
    @Published var meeting = DyteiOSClientBuilder().build()
    @Published var localUserId = ""
    @Published var isLastPage = false
    @Published var isShowRaisedToast = false
    @Published var toastText = ""
    @Published var isShowLeavePopUp = false
    
    var meetingInfo = DyteMeetingInfoV2(
        authToken: "",
        enableAudio: true,
        enableVideo: true,
        baseUrl: "https://api.cluster.dyte.in/v2"
    )
    
    @Published var route: HomeRouting? = nil
    
    @Published var userMeeting: UserMeetingData
    @Published var hostNames: String = ""
    
    @Published var isInit = false
    @Published var isPreview = true
    @Published var isCameraOn = true
    @Published var isAudioOn = true
    @Published var position: CameraPosition = .front
    @Published var isJoined = false
    @Published var isConnecting = false
    @Published var isError = false
    @Published var isLoading = false
    @Published var success = false
    @Published var error: ErrorAlert? = nil
    @Published var hasNewMessage = false
    
    @Published var stringTime = "00:00:00"
    @Published var isNearbyEnd = false
    @Published var isMeetingForceEnd = false
    @Published var futureDate = Date()
    @Published var dateTime = Date()
    @Published var isShowNearEndAlert = false
    
    @Published var isShowingToolbar = true
    @Published var isShowAboutCallBottomSheet = false
    @Published var showingMoreMenu = false
    @Published var isShowingChat = false
    @Published var isShowingQnA = false
    @Published var isShowQuestionBox = false
    @Published var isShowSessionInfo = false
    
    @Published var index = 0
    
    @Published var messageText = ""
    @Published var questionText = ""
    @Published var searchText = ""
    @Published var tabSelection = 0
    @Published var qnaTabSelection = 0
    @Published var isHost = false
    @Published var isRaised = false
    
    @Published var isKicked = false
    
    @Published var questionData = [QuestionData]()
    @Published var questionResponse: QuestionData?
    @Published var isLoadingQuestion: Bool = false
    @Published var isErrorQuestion: Bool = false
    @Published var errorQuestion: String?
    @Published var successQuestion: Bool = false
    @Published var hasNewQuestion = false
    @Published var hasNewParticipantRequest = false
    
    @Published var activePage: Int32 = 1
    
    @Published var connectionError: String?
    
    @Published var bottomSheetTabItems: [TabBarItem] = [
        .init(id: 0, title: LocalizableText.labelChat),
        .init(id: 1, title: LocalizableText.participant)
//        .init(id: 2, title: LocalizableText.labelPolls)
    ]
    
    @Published var qnaTabItems: [TabBarItem] = [
        .init(id: 0, title: LocalizableText.videoCallQuestionsTitle),
        .init(id: 1, title: LocalizableText.videoCallAnsweredTitle)
    ]
    
    @Published var participants = [DyteJoinedMeetingParticipant]()
    @Published var screenShareUser = [DyteScreenShareMeetingParticipant]()
    @Published var screenShareId: DyteScreenShareMeetingParticipant?
    @Published var pinned: DyteJoinedMeetingParticipant?
    @Published var host: DyteJoinedMeetingParticipant?
    @Published var lastActive: DyteJoinedMeetingParticipant?
    @Published var kicked: DyteJoinedMeetingParticipant?
    
    @Published var isRefreshFailed = false
    @Published var isReceivedStageInvite = false
    @Published var isLeaving = false
    
    init(
        backToHome: @escaping () -> Void,
        backToScheduleDetail: @escaping () -> Void,
        meetRepository: MeetingsRepository = MeetingsDefaultRepository(),
        userMeeting: UserMeetingData,
        addDyteParticipantUseCase: AddDyteParticipantUseCase = AddDyteParticipantDefaultUseCase(),
        getQuestionUseCase: GetQuestionUseCase = GetQuestionDefaultUseCase(),
        putQuestionUseCase: PutQuestionUseCase = PutQuestionDefaultUseCase(),
        sendQuestionUseCase: SendQuestionUseCase = SendQuestionDefaultUseCase()
    ) {
        self.backToHome = backToHome
        self.backToScheduleDetail = backToScheduleDetail
        self.meetRepository = meetRepository
        self.userMeeting = userMeeting
        self.futureDate = userMeeting.endAt.orCurrentDate()
        self.addDyteParticipantUseCase = addDyteParticipantUseCase
        self.getQuestionUseCase = getQuestionUseCase
        self.putQuestionUseCase = putQuestionUseCase
        self.sendQuestionUseCase = sendQuestionUseCase
        
        var names: [String] = []
        names.append((userMeeting.user?.name).orEmpty())
        names.append(contentsOf: userMeeting.meetingCollaborations?.compactMap({ item in
            (item.user?.name).orEmpty()
        }) ?? [])
        self.hostNames = names.joined(separator: ", ")
        
    }
    
    func leaveAlertTitle() -> String {
        meeting.localUser.presetName.contains(PresetConstant.host.value) ? LocalizableText.videoCallEndSessionPopupTitle : LocalizableText.videoCallLeavePopupTitle
    }
    
    func leaveAlertSubtitle() -> String {
        meeting.localUser.presetName.contains(PresetConstant.host.value) ? LocalizableText.videoCallEndSessionPopupSubtitle : LocalizableText.videoCallLeavePopupSubtitle
    }
    
    func setPage(to value: Int32) {
        do {
            try self.meeting.participants.setPage(pageNumber: value)
        } catch {
            
        }
    }
    
    
    @MainActor
    func getQuestion() async {
        self.isError = false
        self.error = nil

        let result = await getQuestionUseCase.execute(for: userMeeting.id.orEmpty())

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
    
    @MainActor
    func addParticipant() async {
        self.isConnecting = true
        self.isError = false
        self.error = nil
        
        let result = await addDyteParticipantUseCase.execute(for: userMeeting.id.orEmpty())
        
        switch result {
        case .success(let data):
            self.meetingInfo = DyteMeetingInfoV2(
                authToken: data.token.orEmpty(),
                enableAudio: true,
                enableVideo: true,
                baseUrl: "https://api.cluster.dyte.in/v2"
            )
            self.listenRoomDocument(object: data.roomDocument.orEmpty())
        case .failure(let error):
            handleDefaultError(error: error)
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
            } else {
                self?.isError = true
                self?.error = .api(error.localizedDescription)
            }
        }
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
    
    private func listenRoomDocument(object: String) {
        lazy var databasePathRoomDoc: DatabaseReference? = {
            let ref = Database.database(url: Configuration.shared.environment.firebaseRealtimeURL).reference(withPath: object)
            
            return ref
        }()
        
        guard let databasePathRoomDoc = databasePathRoomDoc else {
            return
        }
        
        databasePathRoomDoc
            .observe(.value) { snapshot, _ in
                guard
                    let json = snapshot.value as? [String: Any]
                else {
                    return
                }
                
                if let qna = json["qnaSent"] as? Bool {
                    self.hasNewQuestion = qna
                }
                
            }
    }
    
    func qnaFiltered() -> [QuestionData] {
        return questionData.filter({ item in
            qnaTabSelection == 0 ? !(item.isAnswered ?? false) : (item.isAnswered ?? false)
        })
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
        
        self.isNearbyEnd = dateTime <= userMeeting.endAt.orCurrentDate().addingTimeInterval(-300)
        
        if hours == 0 && minutes == 0 && seconds == 0 {
            self.checkMeetingEnd()
        }
        
        if minutes == 5 && seconds == 0 && hours == 0 {
            self.isShowNearEndAlert = true
        }
        
        self.stringTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func checkMeetingEnd() {
        onStartFetch()
        
        self.stringTime = "00:00:00"
        
        meetRepository
            .providePostCheckMeetingEnd(meetingId: userMeeting.id.orEmpty())
            .sink { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {[weak self] in
                        if error.statusCode.orZero() == 401 {
                            
                        } else {
                            self?.isLoading = false
                            self?.isError = true
                            
                            self?.error = .api(error.message.orEmpty())
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
    
    func onConnectionError() {
        // Handle connection error
        self.isConnecting = false
        self.isError = true
        self.error = .connection(LocalizableText.videoCallConnectionFailed)
    }
    
    func onJoinFailed() {
        // Handle join failed
        self.isConnecting = false
        self.isError = true
        self.error = .connection(LocalizableText.videoCallFailedJoin)
    }
    
    func onStartFetch() {
        DispatchQueue.main.async {[weak self] in
            self?.isError = false
            self?.isLoading = true
            self?.success = false
            self?.error = nil
        }
    }
    
    func joinMeeting() {
        meeting.joinRoom()
    }
    
    func leaveMeeting() {
        meeting.leaveRoom()
    }
    
    func disableIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func enableIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func toggleCamera() {
        do {
            if isCameraOn {
                try meeting.localUser.disableVideo()
            } else {
                meeting.localUser.enableVideo()
            }
        } catch {
            print("error enable/disable camera")
        }
    }
    
    func toggleMicrophone() {
        do {
            if meeting.localUser.audioEnabled {
                try meeting.localUser.disableAudio()
            } else {
                meeting.localUser.enableAudio()
            }
        } catch {
            print("error enable/disable camera")
        }
    }
    
    func switchCamera() {
        DispatchQueue.main.async { [weak self] in
            if let devices = self?.meeting.localUser.getVideoDevices() {
                if let type = self?.meeting.localUser.getSelectedVideoDevice()?.type {
                    for device in devices {
                        if device.type != type {
                            self?.meeting.localUser.setVideoDevice(dyteVideoDevice: device)
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
    
    func routeToAfterCall() {
        if userMeeting.isInspected ?? true {
            let viewModel = AfterCallViewModel(backToHome: self.backToHome)
            
            DispatchQueue.main.async {[weak self] in
                self?.route = .afterCall(viewModel: viewModel)
            }
        } else {
            let viewModel = FeedbackViewModel(meetingId: userMeeting.id.orEmpty(), backToHome: self.backToHome, backToScheduleDetail: self.backToScheduleDetail)
            
            DispatchQueue.main.async {[weak self] in
                self?.route = .feedbackAfterCall(viewModel: viewModel)
            }
        }
    }
    
    func onDisappear() {
        enableIdleTimer()
    }
    
    func madeToSpeaker() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .videoChat, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    func forceAudioWhenMutedBySystem() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoChat, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    func onAppear() {
        disableIdleTimer()
        getRealTime()
        forceAudioWhenMutedBySystem()
        Task {
            await addParticipant()
            meeting.addMeetingRoomEventsListener(meetingRoomEventsListener: self)
            meeting.addParticipantEventsListener(participantEventsListener: self)
            meeting.addSelfEventsListener(selfEventsListener: self)
            meeting.addParticipantEventsListener(participantEventsListener: self)
            meeting.addChatEventsListener(chatEventsListener: self)
//            meeting.addPollEventsListener(pollEventsListener: self)
            meeting.addRecordingEventsListener(recordingEventsListener: self)
            meeting.addWaitlistEventsListener(waitlistEventsListener: self)
            meeting.addStageEventsListener(stageEventsListener: self)
            meeting.doInit(dyteMeetingInfo_: meetingInfo)
        }
    }
    
    func pinParticipant(_ participant: DyteJoinedMeetingParticipant) {
        do {
            if participant.isPinned {
                try participant.unpin()
            } else {
                try participant.pin()
            }
            
            self.isShowAboutCallBottomSheet = false
            
        } catch {
            print("Error in pinParticipant: \(error)")
            self.isError = true
            self.error = .defaultError(LocalizableText.videoCallFailedPinParticipant)
            
        }
    }
    
    func forceDisableAudio(_ participant: DyteJoinedMeetingParticipant) {
        do {
            try participant.disableAudio()
        } catch {
            print("Error in forceDisableAudio: \(error)")
            self.isError = true
            self.error = .defaultError(LocalizableText.videoCallFailedDisableAudio)
        }
    }
    
    func forceDisableVideo(_ participant: DyteJoinedMeetingParticipant) {
        do {
            try participant.disableVideo()
        } catch {
            print("Error in forceDisableVideo: \(error)")
            self.isError = true
            self.error = .defaultError(LocalizableText.videoCallFailedDisableVideo)
        }
    }
    
    func kickParticipant(_ participant: DyteJoinedMeetingParticipant) {
        do {
            try participant.kick()
        }catch {
            print("Error in kickParticipant: \(error)")
            self.isError = true
            self.error = .defaultError(LocalizableText.videoCallFaiedKickParticipant)
        }
    }
    
    func acceptWaitlisted(_ participant: DyteWaitlistedParticipant) {
        do {
            try participant.acceptWaitListedRequest()
        } catch {
            print("Error in acceptWaitlisted: \(error)")
            self.isError = true
            self.error = .defaultError(LocalizableText.videoCallFailedAcceptWaitlistedRequest)
        }
    }
    
    func sendMessage() {
        do {
            try self.meeting.chat.sendTextMessage(message: messageText)
            self.messageText = ""
        } catch {
            print("Error to send message \(self.messageText): \(error)")
            self.isError = true
            self.error = .defaultError(LocalizableText.videoCallFailedSendMessage)
        }
    }
    
    func acceptAllWaitingRequest() {
        do {
            try self.meeting.participants.acceptAllWaitingRequests()
        } catch {
            print("Error in acceptAllWaitingRequest: \(error)")
            self.isError = true
            self.error = .defaultError(LocalizableText.videoCallFailedAcceptAllRequest)
        }
    }
    
    func createInitial(_ name: String) -> String {
        return name.components(separatedBy: .whitespaces)
                    .filter { !$0.isEmpty }
                    .reduce("") { partialResult, word in
                        partialResult + String((word.first ?? Character("")).uppercased())
                }
    }
    
}

extension GroupVideoCallViewModel: DyteMeetingRoomEventsListener {
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
        }
    }
    
    func onMeetingRoomConnectionFailed() {
        self.onConnectionError()
    }
    
    func onMeetingInitCompleted() {
        if !meeting.localUser.permissions.media.canPublishAudio {
            joinMeeting()
        }
        self.isInit = true
    }
    
    
    func onMeetingInitFailed(exception: KotlinException) {
        self.isInit = false
        self.isError = true
        self.error = .connection(exception.description())
    }
    
    func onMeetingInitStarted() {
        self.isConnecting = true
    }
    
    func onMeetingRoomConnectionError(errorMessage: String) {
        self.isConnecting = false
        self.isError = true
        self.error = .connection(errorMessage)
    }
    
    func onMeetingRoomDisconnected() {
        
    }
    
    func onMeetingRoomJoinCompleted() {
        self.setPage(to: 0)
        self.participants = meeting.participants.active
        self.screenShareUser = meeting.participants.screenshares
        self.screenShareId = meeting.participants.screenshares.first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.host = self?.meeting.participants.joined.first(where: { item in
                item.presetName.contains(PresetConstant.host.value)
            })
            self?.lastActive = self?.meeting.participants.activeSpeaker
        }
        
        withAnimation {
            self.isJoined = true
        }
        self.isConnecting = false
        self.isPreview = false
        self.pinned = meeting.participants.pinned
        self.localUserId = meeting.localUser.userId
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
        self.isRaised = false
    }
    
    func onReconnectingToMeetingRoom() {
        self.isConnecting = true
    }
    
}

extension GroupVideoCallViewModel: DyteParticipantEventsListener {
    func onActiveSpeakerChanged(participant: DyteJoinedMeetingParticipant) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.host = self?.meeting.participants.joined.first(where: { item in
                item.presetName.contains(PresetConstant.host.value)
            })
            self?.lastActive = self?.meeting.participants.activeSpeaker
        }
    }
    
    func onParticipantJoin(participant: DyteJoinedMeetingParticipant) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.host = self?.meeting.participants.joined.first(where: { item in
                item.presetName.contains(PresetConstant.host.value)
            })
            self?.lastActive = self?.meeting.participants.activeSpeaker
        }
        self.participants = meeting.participants.active
    }
    
    func onParticipantLeave(participant: DyteJoinedMeetingParticipant) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.host = self?.meeting.participants.joined.first(where: { item in
                item.presetName.contains(PresetConstant.host.value)
            })
            self?.lastActive = self?.meeting.participants.activeSpeaker
        }
        self.participants = meeting.participants.active
    }
    
    func onParticipantPinned(participant: DyteJoinedMeetingParticipant) {
        self.pinned = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            self.pinned = participant
            self.index = 0
        }
    }
    
    func onParticipantUnpinned(participant: DyteJoinedMeetingParticipant) {
        self.pinned = nil
        
        self.participants = self.meeting.participants.active
        self.index = 1
    }
    
    func onScreenShareEnded(participant: DyteScreenShareMeetingParticipant) {
        if meeting.participants.screenshares.count != screenShareUser.count {
            self.screenShareUser = meeting.participants.screenshares
        }
        if self.screenShareId == nil || self.meeting.participants.screenshares.count <= 1 {
            self.screenShareId = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                self.screenShareId = self.meeting.participants.screenshares.last
            }
        }
        
        if self.meeting.participants.screenshares.isEmpty {
            self.index = 1
        }
    }
    
    func onScreenShareStarted(participant: DyteScreenShareMeetingParticipant) {
        if meeting.participants.screenshares.count != screenShareUser.count {
            self.screenShareUser = meeting.participants.screenshares
        }
        if self.screenShareId == nil || self.meeting.participants.screenshares.count <= 1 {
            self.screenShareId = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                self.screenShareId = self.meeting.participants.screenshares.first
            }
        }
        
        if self.meeting.participants.screenshares.isEmpty {
            self.index = 0
        }
    }
    
    func onActiveParticipantsChanged(active: [DyteJoinedMeetingParticipant]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.host = self?.meeting.participants.joined.first(where: { item in
                item.presetName.contains(PresetConstant.host.value)
            })
            self?.lastActive = self?.meeting.participants.activeSpeaker
        }
        self.participants = meeting.participants.active
    }
    
    func onActiveSpeakerChanged(participant: DyteMeetingParticipant) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.host = self?.meeting.participants.joined.first(where: { item in
                item.presetName.contains(PresetConstant.host.value)
            })
            self?.lastActive = self?.meeting.participants.activeSpeaker
        }
        self.participants = meeting.participants.active
    }
    
    func onAudioUpdate(audioEnabled: Bool, participant: DyteMeetingParticipant) {
        self.participants = meeting.participants.active
    }
    
    func onNoActiveSpeaker() {
        
    }
    
    func onScreenSharesUpdated() {
        if meeting.participants.screenshares.count != screenShareUser.count {
            self.screenShareUser = meeting.participants.screenshares
        }
    }
    
    func onUpdate(participants: DyteRoomParticipants) {
        self.participants = meeting.participants.active
    }
    
    func onVideoUpdate(videoEnabled: Bool, participant: DyteMeetingParticipant) {
        self.participants = meeting.participants.active
    }
    
}

extension GroupVideoCallViewModel: DyteSelfEventsListener {
    func onStageStatusUpdated(stageStatus: StageStatus) {
        
    }
    
    func onRoomMessage(message: String) {
        
    }
    
    func onAudioDevicesUpdated() {
        
    }
    
    func onAudioUpdate(audioEnabled: Bool) {
        isAudioOn = audioEnabled
        
        if audioEnabled {
            forceAudioWhenMutedBySystem()
        } else {
            madeToSpeaker()
        }
    }
    
    func onMeetingRoomJoinedWithoutCameraPermission() {
        
    }
    
    func onMeetingRoomJoinedWithoutMicPermission() {
        
    }
    
    func onProximityChanged(isNear: Bool) {
        
    }
    
    func onRemovedFromMeeting() {
        isError = false
        isKicked = true
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

extension GroupVideoCallViewModel: DyteChatEventsListener {
    func onChatUpdates(messages: [DyteChatMessage]) {
        
    }
    
    func onNewChatMessage(message: DyteChatMessage) {
        hasNewMessage = true
    }
    
}

//extension GroupVideoCallViewModel: DytePollEventsListener {
//    func onNewPoll(poll: DytePollMessage) {
//
//    }
//
//    func onPollUpdates(pollMessages: [DytePollMessage]) {
//
//    }
//
//}

extension GroupVideoCallViewModel: DyteRecordingEventsListener {
    func onMeetingRecordingEnded() {
        
    }
    
    func onMeetingRecordingStarted() {
        
    }
    
    func onMeetingRecordingStateUpdated(state: DyteRecordingState) {
        
    }
    
    func onMeetingRecordingStopError(e: KotlinException) {
        
    }
    
}

extension GroupVideoCallViewModel: DyteWaitlistEventsListener {
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

extension GroupVideoCallViewModel: DyteStageEventListener {
    func onParticipantRemovedFromStage(participant: DyteJoinedMeetingParticipant) {
        
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
        
        self.meeting.localUser.enableVideo()
        do {
            try self.meeting.localUser.disableAudio()
            try self.meeting.localUser.disableVideo()
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
