//
//  GroupVideoCallViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/23.
//

import Combine
import DyteiOSCore
import UIKit
import SwiftUI
import DinotisDesignSystem
import DinotisData

struct DummyQuestion: Identifiable {
    let id = UUID()
    var date: Date
    var name: String
    var question: String
}

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

final class GroupVideoCallViewModel: ObservableObject {
    private var timer: Timer?
    
    var backToRoot: () -> Void
    var backToHome: () -> Void
    
    private let meetRepository: MeetingsRepository
    private let addDyteParticipantUseCase: AddDyteParticipantUseCase
    private var cancellables = Set<AnyCancellable>()
    
    let meeting = DyteiOSClientBuilder().build()
    var localUserId = ""
    
//    let meetingInfo = DyteMeetingInfoV2(
//        authToken: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJvcmdJZCI6IjQ2ODdlYjllLWMyNjItNDhmOS1iZWI0LTQ3ODhiNjJlYjY4YSIsIm1lZXRpbmdJZCI6ImJiYjBiMDk0LTY2MmEtNDllMS1hMTk4LTViNGQ0ODcwYmVjOSIsInBhcnRpY2lwYW50SWQiOiJhYWE5ZDUzMS1hODU1LTRhNGUtYTMxYS05Yjg1NDEyNzcxZDUiLCJwcmVzZXRJZCI6IjcyMDA2ZmQ4LWUxYjItNGZiMS05MGQzLWIxNDg3NmUwZjkyMSIsImlhdCI6MTY4OTU4NTg5MCwiZXhwIjoxNjk4MjI1ODkwfQ.dCaZ5JTSYM8sHx2Ge5cl58pM8j-wXIUCD_bASgdD6CeBKsxrHbZxv7LGGP1F4_6iYZya2Y7APxMUIIeFWp4sjQqUnjKcwo1_jhVDzl6pkC0aBdPa9r0ZunfG80Gix-LBM223pX8FJC914nIFffbxG8xKb9UkoRo73SmP9xEX8Ak5V6KO8yLtBLZI1wFO7YcEffx36uRQjRXMv8xFrH148fxIlbNNAIqhXwfaZ2dAi14hv359SY9PYnJI008BaAOaOFNJE0d-ka41wVO3WBTS14g8P2r5R3tDYfyFuWV8z0HroBO35e1fP2KAyZ0LVbpzsM3A8TfEWfHuOs_R4yURSw",
//        enableAudio: true,
//        enableVideo: true,
//        baseUrl: "https://api.cluster.dyte.in/v2"
//    )
    
    var meetingInfo = DyteMeetingInfoV2(
        authToken: "",
        enableAudio: true,
        enableVideo: true,
        baseUrl: "https://api.cluster.dyte.in/v2"
    )
    
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
    @Published var error: String?
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
    
    @Published var bottomSheetTabItems: [TabBarItem] = [
        .init(id: 0, title: LocalizableText.labelChat),
        .init(id: 1, title: LocalizableText.participant),
        .init(id: 2, title: LocalizableText.labelPolls)
    ]
    
    @Published var qnaTabItems: [TabBarItem] = [
        .init(id: 0, title: "Questions"),
        .init(id: 1, title: "Answered")
    ]
    
    @Published var dummyParicipant: [DummyParticipantModel] = [
        .init(name: "Ahmad Rifai", isMicOn: false, isVideoOn: false, isJoining: false, isSpeaker: true),
        .init(name: "Bambanb", isMicOn: true, isVideoOn: false, isJoining: false, isSpeaker: true),
        .init(name: "Citra Kirana", isMicOn: false, isVideoOn: false, isJoining: true, isSpeaker: false),
        .init(name: "Dimas Agung", isMicOn: false, isVideoOn: false, isJoining: false, isSpeaker: false),
        .init(name: "Endika Koala", isMicOn: false, isVideoOn: false, isJoining: true, isSpeaker: false),
        .init(name: "Faris van Java", isMicOn: false, isVideoOn: false, isJoining: false, isSpeaker: false)
    ]
    
    @Published var dummyQuestionList: [DummyQuestion] = [
        .init(date: .now, name: "Wade Warren", question: "Lorem ipsum dolor sit amet consectetur. Nec leosdsdLorem ipsum dolor sit amet consectetur. Nec leo.."),
        .init(date: .now, name: "Mr. Singh", question: "Lorem ipsum dolor sit amet consectetur."),
        .init(date: .now, name: "Abrar Maulana", question: "Lorem ipsum dolor sit amet consectetur. Nec leosdsdLorem ipsum dolor"),
        .init(date: .now, name: "Xavier", question: "Lorem ipsum dolor sit amet consectetur. Lorem ipsum dolor sit amet consectetur Lorem ipsum dolor sit amet consectetur")
    ]
    
    @Published var dummyAnsweredList: [DummyQuestion] = []
    
    var searchedParticipant: [DummyParticipantModel] {
        if searchText.isEmpty {
            return dummyParicipant
        } else {
            return dummyParicipant.filter({ $0.name.contains(searchText) })
        }
    }
    
    var joiningParticipant: [DummyParticipantModel] {
        searchedParticipant.filter({ $0.isJoining })
    }
    
    var speakerParticipant: [DummyParticipantModel] {
        searchedParticipant.filter({ $0.isSpeaker && $0.isJoining == false })
    }
    
    var viewerSpeaker: [DummyParticipantModel] {
        searchedParticipant.filter({ $0.isSpeaker == false && $0.isJoining == false })
    }
    
    @Published var participants = [DyteJoinedMeetingParticipant]()
    @Published var localUser: DyteSelfParticipant? = nil
    @Published var screenShareUser = [DyteScreenShareMeetingParticipant]()
    @Published var screenShareId: DyteScreenShareMeetingParticipant?
    @Published var pinned: DyteJoinedMeetingParticipant?
    @Published var kicked: DyteJoinedMeetingParticipant?
    
    @Published var isRefreshFailed = false
    
    init(
        backToRoot: @escaping () -> Void,
        backToHome: @escaping () -> Void,
        meetRepository: MeetingsRepository = MeetingsDefaultRepository(),
        userMeeting: UserMeetingData,
        addDyteParticipantUseCase: AddDyteParticipantUseCase = AddDyteParticipantDefaultUseCase()
    ) {
        self.backToHome = backToHome
        self.backToRoot = backToRoot
        self.meetRepository = meetRepository
        self.userMeeting = userMeeting
        self.futureDate = userMeeting.endAt.orCurrentDate()
        self.addDyteParticipantUseCase = addDyteParticipantUseCase
        
        var names: [String] = []
        names.append((userMeeting.user?.name).orEmpty())
        names.append(contentsOf: userMeeting.meetingCollaborations?.compactMap({ item in
            (item.user?.name).orEmpty()
        }) ?? [])
        self.hostNames = names.joined(separator: ", ")
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
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isConnecting = false
            
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
    
    func answerQuestion(at index: Int) {
        withAnimation {
            dummyAnsweredList.append(dummyQuestionList[index])
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [weak self] in
                self?.dummyQuestionList.remove(at: index)
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
    
    func unanswerQuestion(at index: Int) {
        withAnimation {
            dummyQuestionList.append(dummyAnsweredList[index])
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [weak self] in
                self?.dummyAnsweredList.remove(at: index)
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
            if isAudioOn {
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
    
    func onDisappear() {
        enableIdleTimer()
    }
    
    func onAppear() {
        disableIdleTimer()
        Task {
            getRealTime()
            await addParticipant()
            meeting.addMeetingRoomEventsListener(meetingRoomEventsListener: self)
            meeting.addParticipantEventsListener(participantEventsListener: self)
            meeting.addSelfEventsListener(selfEventsListener: self)
            meeting.addParticipantEventsListener(participantEventsListener: self)
            meeting.addChatEventsListener(chatEventsListener: self)
            meeting.addPollEventsListener(pollEventsListener: self)
            meeting.addRecordingEventsListener(recordingEventsListener: self)
            meeting.addWaitlistEventsListener(waitlistEventsListener: self)
            meeting.addWebinarEventsListener(webinarEventsListener: self)
            meeting.doInit(dyteMeetingInfo_: meetingInfo)
        }
    }
    
    func sendMessage() {
        do {
            try self.meeting.chat.sendTextMessage(message: messageText)
            self.messageText = ""
        } catch {
            print("Error to send message \(self.messageText)")
        }
    }
    
    func filteredViewerParticipants() -> [DyteJoinedMeetingParticipant] {
        meeting.participants.joined.filter({ item in
                !meeting.participants.active.contains(where: { part in
                    item.id == part.id
                })
            })
    }
    
    func acceptAllWaitingRequest() {
        do {
            try self.meeting.participants.acceptAllWaitingRequests()
        }catch {
            
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
        
    }
    
    func onMeetingRoomConnectionFailed() {
        self.isConnecting = false
    }
    
    func onDisconnectedFromMeetingRoom(reason: String) {
        
    }
    
    func onMeetingInitCompleted() {
        self.localUser = meeting.localUser
        if !meeting.localUser.permissions.media.canPublishAudio {
            joinMeeting()
        }
        self.isInit = true
        
    }
    
    func onMeetingInitFailed(exception: KotlinException) {
        self.isInit = false
    }
    
    func onMeetingInitStarted() {
        self.isConnecting = true
    }
    
    func onMeetingRoomConnectionError(errorMessage: String) {
        
    }
    
    func onMeetingRoomDisconnected() {
        
    }
    
    func onMeetingRoomJoinCompleted() {
        self.participants = meeting.participants.active
        self.screenShareUser = meeting.participants.screenshares
        self.screenShareId = meeting.participants.screenshares.first
        withAnimation {
            self.isJoined = true
        }
        self.isConnecting = false
        self.isPreview = false
        self.pinned = meeting.participants.pinned
        self.localUserId = meeting.localUser.userId
       
    }
    
    func onMeetingRoomJoinFailed(exception: KotlinException) {
        
    }
    
    func onMeetingRoomJoinStarted() {
        self.isConnecting = true
    }
    
    func onMeetingRoomLeaveCompleted() {
        self.isInit = false
        self.isJoined = false
        backToHome()
    }
    
    func onMeetingRoomLeaveStarted() {
        
    }
    
    func onMeetingRoomReconnectionFailed() {
        self.isConnecting = false
    }
    
    func onReconnectedToMeetingRoom() {
        self.isConnecting = false
    }
    
    func onReconnectingToMeetingRoom() {
        self.isConnecting = true
    }
    
}

extension GroupVideoCallViewModel: DyteParticipantEventsListener {
    func onActiveSpeakerChanged(participant: DyteJoinedMeetingParticipant) {
        
    }
    
    func onParticipantJoin(participant: DyteJoinedMeetingParticipant) {
        self.participants.removeAll()
        self.participants = meeting.participants.active
    }
    
    func onParticipantLeave(participant: DyteJoinedMeetingParticipant) {
        self.participants.removeAll()
        self.participants = meeting.participants.active
    }
    
    func onParticipantPinned(participant: DyteJoinedMeetingParticipant) {
        self.pinned = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            self.pinned = participant
        }
    }
    
    func onParticipantUnpinned(participant: DyteJoinedMeetingParticipant) {
        self.pinned = nil
        
        self.participants = self.meeting.participants.active
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
    }
    
    func onActiveParticipantsChanged(active: [DyteJoinedMeetingParticipant]) {
        self.participants.removeAll()
        self.participants = meeting.participants.active
    }
    
    func onActiveSpeakerChanged(participant: DyteMeetingParticipant) {
        
    }
    
    func onAudioUpdate(audioEnabled: Bool, participant: DyteMeetingParticipant) {
        self.participants.removeAll()
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
        self.participants.removeAll()
        self.participants = meeting.participants.active
    }
    
    func onVideoUpdate(videoEnabled: Bool, participant: DyteMeetingParticipant) {
        self.participants.removeAll()
        self.participants = meeting.participants.active
    }
    
}

extension GroupVideoCallViewModel: DyteSelfEventsListener {
    func onStageStatusUpdated(stageStatus: StageStatus) {
        localUser = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) {
            self.localUser = self.meeting.localUser
        }
    }
    
    func onRoomMessage(message: String) {
        
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
    
    func onWebinarPresentRequestReceived() {
        
    }
    
}

extension GroupVideoCallViewModel: DyteChatEventsListener {
    func onChatUpdates(messages: [DyteChatMessage]) {
        
    }
    
    func onNewChatMessage(message: DyteChatMessage) {
        hasNewMessage = true
    }
    
}

extension GroupVideoCallViewModel: DytePollEventsListener {
    func onNewPoll(poll: DytePollMessage) {
        
    }
    
    func onPollUpdates(pollMessages: [DytePollMessage]) {
        
    }
    
}

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
        
    }
    
    func onWaitListParticipantRejected(participant: DyteWaitlistedParticipant) {
        
    }
    
    func onWaitListParticipantAccepted(participant: DyteMeetingParticipant) {
        
    }
    
    func onWaitListParticipantClosed(participant: DyteMeetingParticipant) {
        
    }
    
    func onWaitListParticipantJoined(participant: DyteMeetingParticipant) {
        
    }
    
    func onWaitListParticipantRejected(participant: DyteMeetingParticipant) {
        
    }
    
}

extension GroupVideoCallViewModel: DyteWebinarEventsListener {
    func onAddedToStage() {
        // when this user is joined to stage
        localUser = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) {
            self.localUser = self.meeting.localUser
        }
    }
    func onPresentRequestClosed(participant: RequestToPresentParticipant) {
        // when a user who was trying to join stage leaves the call.
    }
    func onPresentRequestReceived() {
        // when host requests this user to join stage. Here one should give choice to either accept the request or decline it.
    }
    func onPresetRequestAccepted(participant: RequestToPresentParticipant) {
        // when a join stage request is accepted by host
    }
    func onPresetRequestAdded(participant: RequestToPresentParticipant) {
        // when a user is requesting to join the stage
        self.isRaised = true
        
    }
    func onPresetRequestRejected(participant: RequestToPresentParticipant) {
        // when a join stage request is denied by host
    }
    func onPresetRequestWithdrawn(participant: RequestToPresentParticipant) {
        // when a user who was trying to join stage withdraws their request to join.
        self.isRaised = false
    }
    func onRemovedFromStage() {
        // when this user is no longer on stage
    }
}
