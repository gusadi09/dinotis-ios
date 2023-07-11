//
//  GroupVideoCallViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/23.
//

import Foundation
import DyteiOSCore
import UIKit
import SwiftUI
import DinotisDesignSystem


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

final class GroupVideoCallViewModel: ObservableObject {
    private var timer: Timer?
    
    var backToRoot: () -> Void
    var backToHome: () -> Void
    
    let meeting = DyteiOSClientBuilder().build()
    var localUserId = ""
    
    let meetingInfo = DyteMeetingInfoV2(
        authToken: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJvcmdJZCI6IjQ2ODdlYjllLWMyNjItNDhmOS1iZWI0LTQ3ODhiNjJlYjY4YSIsIm1lZXRpbmdJZCI6ImJiYjczNDg4LTA2NTctNDIzZC1hM2QxLWY2NjQ1Mjk3OTA1YyIsInBhcnRpY2lwYW50SWQiOiJhYWFjNzMzZS0wNDQxLTQyNzMtYTRhNy01NWQ5NGUyMTA3NmMiLCJwcmVzZXRJZCI6Ijk5YmZlNTZkLWVhYjMtNGMyNy05ZTQwLTEyMGY3ZTg0OWI3NyIsImlhdCI6MTY4NzMzMjYyNywiZXhwIjoxNjk1OTcyNjI3fQ.Wukf5VcOrjSAGBraH66WSrypR59AHfVeK7OfAfUVA7TMcy6TSj98UVWMB_fwpYXDxL9cAtZHyzadFlkUQ1WbPHiXJ-ZpE0UyE44QNk7AxlnczBv_QyKmLwG2LReXxNSNsDnnq3LPQFYWWh_26z0Cac2UVzwc4HjSD29YxO4-0tsd1cORsgSFaeysshhrf3ZmyNSv3mw5BFFePd5pwuzdX6wk5l5-HQAgEcvNyyzCIHMXzynGcbhv-2WziFNRu7FyIPQZFDiZVTZOzoo_r9f3PDogRCHf7HZ3UZAZP_gHr0LjwJk7zzTwMis-6pGuxz99rBfqskQg2_kdl5EVhIIt-Q",
        
        /// Irham's Vidcall token (Host)
//        authToken: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJvcmdJZCI6Ijk4YWE2YWVlLTY4MTUtNDE4Yi04OTk5LWQzNjE4MzliN2IyYSIsIm1lZXRpbmdJZCI6ImJiYmY1NTg5LTQwMWYtNGY5MS1hOTI2LTY5MzZhMjY2ODRmNyIsInBhcnRpY2lwYW50SWQiOiJhYWFjYjczZC1hZGE3LTQ2MmMtYWM2Yi01ZGRkN2FmN2E5YTIiLCJwcmVzZXRJZCI6IjBiYjBjZDgyLTYxZjEtNDkwZi05ZmQ3LTcwMjYyNGEzNmFiMSIsImlhdCI6MTY4ODk2NjkzNywiZXhwIjoxNjk3NjA2OTM3fQ.NjbI_C_aU3hsOWydP2c4UBu-fcnDw8oM4cAUVVmFvHf6a5e2gKL3Or8NyqQ7_Q_nFRU2qmFwGomavwTYEILf1RUsiL0hM8W9RT85_Sq0GMd4ycOnj16oMrM6x70EHzQCLjZmDl9wFhAn59MZUEVVfoHyXjUv5ocTiVUpaUqedmf0G0QH3ijpzfeaZVMOo9KCPuYYWpBt7dgtoelnnuEG_ty_ixmKrA_-9T7X5Op2OdnNVVehy4r7iJSR4EVXwdvEAnBtZ4IaBI_S-hM-bGlmzvkhsmj7e3hQEi9R8KlnE0ro6NcIERSjtei5OfOBMN_HFdYbdqcGF6pm1Fs9l_V_dA",
        enableAudio: true,
        enableVideo: true,
        baseUrl: "https://api.cluster.dyte.in/v2"
    )
    
    @Published var isInit = false
    @Published var isCameraOn = true
    @Published var isAudioOn = true
    @Published var position: CameraPosition = .front
    @Published var isJoined = false
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
    
    @Published var index = 0
    
    @Published var messageText = ""
    @Published var questionText = ""
    @Published var searchText = ""
    @Published var tabSelection = 0
    @Published var qnaTabSelection = 0
    @Published var isHost = false
    
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
    
    init(
        backToRoot: @escaping () -> Void,
        backToHome: @escaping () -> Void
    ) {
        self.backToHome = backToHome
        self.backToRoot = backToRoot
    }
    
    func answerQuestion(at index: Int) {
        withAnimation {
            dummyAnsweredList.append(dummyQuestionList[index])
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [weak self] in
                self?.dummyQuestionList.remove(at: index)
            }
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
        
//        self.isNearbyEnd = dateTime <= meeting.endAt.orCurrentDate().addingTimeInterval(-300)
        
//        if hours == 0 && minutes == 0 && seconds == 0 {
//            self.checkMeetingEnd()
//        }
        
//        withAnimation {
//            self.isShowNearEndAlert = minutes == 5 && seconds == 0 && hours == 0
//        }

        self.stringTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
        getRealTime()
        meeting.addMeetingRoomEventsListener(meetingRoomEventsListener: self)
        meeting.addParticipantEventsListener(participantEventsListener: self)
        meeting.addSelfEventsListener(selfEventsListener: self)
        meeting.addParticipantEventsListener(participantEventsListener: self)
        meeting.addChatEventsListener(chatEventsListener: self)
        meeting.addPollEventsListener(pollEventsListener: self)
        meeting.addRecordingEventsListener(recordingEventsListener: self)
        meeting.addWaitlistEventsListener(waitlistEventsListener: self)
        meeting.doInit(dyteMeetingInfo_: meetingInfo)
    }
    
    func sendMessage() {
        do {
            try self.meeting.chat.sendTextMessage(message: messageText)
            self.messageText = ""
        } catch {
            print("Error to send message \(self.messageText)")
        }
    }
}

extension GroupVideoCallViewModel: DyteMeetingRoomEventsListener {
    func onConnectedToMeetingRoom() {
        
    }
    
    func onConnectingToMeetingRoom() {
        
    }
    
    func onDisconnectedFromMeetingRoom() {
        
    }
    
    func onMeetingRoomConnectionFailed() {
        
    }
    
    func onDisconnectedFromMeetingRoom(reason: String) {
        
    }
    
    func onMeetingInitCompleted() {
        self.isInit = true
    }
    
    func onMeetingInitFailed(exception: KotlinException) {
        self.isInit = false
    }
    
    func onMeetingInitStarted() {
        
    }
    
    func onMeetingRoomConnectionError(errorMessage: String) {
        
    }
    
    func onMeetingRoomDisconnected() {
        
    }
    
    func onMeetingRoomJoinCompleted() {
        self.participants = meeting.participants.active
        self.localUser = meeting.localUser
        self.isJoined = true
        self.localUserId = meeting.localUser.userId
    }
    
    func onMeetingRoomJoinFailed(exception: KotlinException) {
        
    }
    
    func onMeetingRoomJoinStarted() {
    
    }
    
    func onMeetingRoomLeaveCompleted() {
        self.isInit = false
        self.isJoined = false
        backToHome()
    }
    
    func onMeetingRoomLeaveStarted() {
        
    }
    
    func onMeetingRoomReconnectionFailed() {
        
    }
    
    func onReconnectedToMeetingRoom() {
        
    }
    
    func onReconnectingToMeetingRoom() {
        
    }
    
}

extension GroupVideoCallViewModel: DyteParticipantEventsListener {
    func onActiveSpeakerChanged(participant: DyteJoinedMeetingParticipant) {
        
    }
    
    func onParticipantJoin(participant: DyteJoinedMeetingParticipant) {
        
    }
    
    func onParticipantLeave(participant: DyteJoinedMeetingParticipant) {
        
    }
    
    func onParticipantPinned(participant: DyteJoinedMeetingParticipant) {
        
    }
    
    func onParticipantUnpinned(participant: DyteJoinedMeetingParticipant) {
        
    }
    
    func onScreenShareEnded(participant: DyteScreenShareMeetingParticipant) {
        
    }
    
    func onScreenShareStarted(participant: DyteScreenShareMeetingParticipant) {
        
    }
    
    func onActiveParticipantsChanged(active: [DyteJoinedMeetingParticipant]) {
        
    }
    
    func onActiveSpeakerChanged(participant: DyteMeetingParticipant) {
        
    }
    
    func onAudioUpdate(audioEnabled: Bool, participant: DyteMeetingParticipant) {
        self.participants.removeAll()
        self.participants = meeting.participants.active
    }
    
    func onNoActiveSpeaker() {
        
    }
    
    func onParticipantJoin(participant: DyteMeetingParticipant) {
        self.participants.removeAll()
        self.participants = meeting.participants.active
    }
    
    func onParticipantLeave(participant: DyteMeetingParticipant) {
        self.participants.removeAll()
        self.participants = meeting.participants.active
    }
    
    func onParticipantPinned(participant: DyteMeetingParticipant) {
        
    }
    
    func onParticipantUnpinned(participant: DyteMeetingParticipant) {
        
    }
    
    func onScreenShareEnded(participant: DyteMeetingParticipant) {
        
    }
    
    func onScreenShareStarted(participant: DyteMeetingParticipant) {
        
    }
    
    func onScreenSharesUpdated() {
        
    }
    
    func onUpdate(participants: DyteRoomParticipants) {
        
    }
    
    func onVideoUpdate(videoEnabled: Bool, participant: DyteMeetingParticipant) {
        self.participants.removeAll()
        self.participants = meeting.participants.active
    }
    
}

extension GroupVideoCallViewModel: DyteSelfEventsListener {
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
        
    }
    
    func onStoppedPresenting() {
        
    }
    
    func onUpdate(participant_ participant: DyteSelfParticipant) {
        
    }
    
    func onVideoUpdate(videoEnabled: Bool) {
        isCameraOn = videoEnabled
    }
    
    func onWaitListStatusUpdate(waitListStatus: WaitListStatus) {
        
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
