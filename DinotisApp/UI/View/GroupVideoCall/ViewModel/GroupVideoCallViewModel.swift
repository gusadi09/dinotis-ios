//
//  GroupVideoCallViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/23.
//

import Foundation
import DyteiOSCore
import UIKit

enum CameraPosition {
    case front
    case rear
}

final class GroupVideoCallViewModel: ObservableObject {
    var backToRoot: () -> Void
    var backToHome: () -> Void
    
    let meeting = DyteiOSClientBuilder().build()
    
    let meetingInfo = DyteMeetingInfoV2(
        authToken: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJvcmdJZCI6IjQ2ODdlYjllLWMyNjItNDhmOS1iZWI0LTQ3ODhiNjJlYjY4YSIsIm1lZXRpbmdJZCI6ImJiYjczNDg4LTA2NTctNDIzZC1hM2QxLWY2NjQ1Mjk3OTA1YyIsInBhcnRpY2lwYW50SWQiOiJhYWFjNzMzZS0wNDQxLTQyNzMtYTRhNy01NWQ5NGUyMTA3NmMiLCJwcmVzZXRJZCI6Ijk5YmZlNTZkLWVhYjMtNGMyNy05ZTQwLTEyMGY3ZTg0OWI3NyIsImlhdCI6MTY4NzMzMjYyNywiZXhwIjoxNjk1OTcyNjI3fQ.Wukf5VcOrjSAGBraH66WSrypR59AHfVeK7OfAfUVA7TMcy6TSj98UVWMB_fwpYXDxL9cAtZHyzadFlkUQ1WbPHiXJ-ZpE0UyE44QNk7AxlnczBv_QyKmLwG2LReXxNSNsDnnq3LPQFYWWh_26z0Cac2UVzwc4HjSD29YxO4-0tsd1cORsgSFaeysshhrf3ZmyNSv3mw5BFFePd5pwuzdX6wk5l5-HQAgEcvNyyzCIHMXzynGcbhv-2WziFNRu7FyIPQZFDiZVTZOzoo_r9f3PDogRCHf7HZ3UZAZP_gHr0LjwJk7zzTwMis-6pGuxz99rBfqskQg2_kdl5EVhIIt-Q",
        enableAudio: true,
        enableVideo: true,
        baseUrl: "https://api.cluster.dyte.in/v2"
    )
    
    @Published var isInit = false
    @Published var isCameraOn = true
    @Published var isAudioOn = true
    @Published var position: CameraPosition = .front
    @Published var isJoined = false
    
    @Published var stringTime = "00:00:00"
    @Published var isNearbyEnd = false
    
    @Published var isShowingToolbar = true
    @Published var isShowAboutCallBottomSheet = false
    @Published var showingMoreMenu = false
    @Published var isShowingChat = false
    
    @Published var index = 0
    
    @Published var participants = [DyteJoinedMeetingParticipant]()
    @Published var localUser: DyteSelfParticipant? = nil
    
    init(
        backToRoot: @escaping () -> Void,
        backToHome: @escaping () -> Void
    ) {
        self.backToHome = backToHome
        self.backToRoot = backToRoot
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
                for device in devices {
                    if device.type != self?.meeting.localUser.getSelectedVideoDevice().type {
                        self?.meeting.localUser.setVideoDevice(dyteVideoDevice: device)
                        if self?.position == .front {
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
    
    func onDisappear() {
        enableIdleTimer()
    }
    
    func onAppear() {
        disableIdleTimer()
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
}

extension GroupVideoCallViewModel: DyteMeetingRoomEventsListener {
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
    func onWaitListParticipantAccepted(participant: DyteMeetingParticipant) {
        
    }
    
    func onWaitListParticipantClosed(participant: DyteMeetingParticipant) {
        
    }
    
    func onWaitListParticipantJoined(participant: DyteMeetingParticipant) {
        
    }
    
    func onWaitListParticipantRejected(participant: DyteMeetingParticipant) {
        
    }
    
}
