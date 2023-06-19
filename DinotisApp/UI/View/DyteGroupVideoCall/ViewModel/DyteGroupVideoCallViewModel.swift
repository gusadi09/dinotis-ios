//
//  GroupVideoCallViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/06/23.
//

import Foundation
import DyteiOSCore
import DinotisData

final class DyteGroupVideoCallViewModel: ObservableObject {
    var backToRoot: (() -> Void)
    var backToHome: (() -> Void)
    
    let meetingDyte = DyteiOSClientBuilder().build()
    let meetingInfo = DyteMeetingInfoV2(
        authToken: "",
        enableAudio: true,
        enableVideo: true,
        baseUrl: "https://api.cluster.dyte.in/v2"
    )
    
    @Published var isJoined = false
    
    init(
        backToRoot: @escaping (() -> Void),
        backToHome: @escaping (() -> Void)
    ) {
        
        self.backToHome = backToHome
        self.backToRoot = backToRoot
        
        meetingDyte.doInit(dyteMeetingInfo_: meetingInfo)
        meetingDyte.addMeetingRoomEventsListener(meetingRoomEventsListener: self)
        meetingDyte.addParticipantEventsListener(participantEventsListener: self)
        meetingDyte.addSelfEventsListener(selfEventsListener: self)
        meetingDyte.addParticipantEventsListener(participantEventsListener: self)
        meetingDyte.addChatEventsListener(chatEventsListener: self)
        meetingDyte.addPollEventsListener(pollEventsListener: self)
        meetingDyte.addRecordingEventsListener(recordingEventsListener: self)
        meetingDyte.addWaitlistEventsListener(waitlistEventsListener: self)
    }
    
    func onJoinRoom() {
        meetingDyte.joinRoom()
    }
    
    func onLeaveRoom() {
        meetingDyte.leaveRoom()
    }
}

extension DyteGroupVideoCallViewModel: DyteSelfEventsListener {
    func onAudioDevicesUpdated() {
        
    }
    
    func onAudioUpdate(audioEnabled: Bool) {
        
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
        
    }
    
    func onWaitListStatusUpdate(waitListStatus: WaitListStatus) {
        
    }
    
    func onWebinarPresentRequestReceived() {
        
    }
}

extension DyteGroupVideoCallViewModel: DyteParticipantEventsListener {
    func onActiveParticipantsChanged(active: [DyteJoinedMeetingParticipant]) {
        
    }
    
    func onActiveSpeakerChanged(participant: DyteMeetingParticipant) {
        
    }
    
    func onAudioUpdate(audioEnabled: Bool, participant: DyteMeetingParticipant) {
        
    }
    
    func onNoActiveSpeaker() {
        
    }
    
    func onParticipantJoin(participant: DyteMeetingParticipant) {
        
    }
    
    func onParticipantLeave(participant: DyteMeetingParticipant) {
        
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
        
    }
}

extension DyteGroupVideoCallViewModel: DyteMeetingRoomEventsListener {
    func onDisconnectedFromMeetingRoom(reason: String) {
        
    }
    
    func onMeetingInitCompleted() {
        
    }
    
    func onMeetingInitFailed(exception: KotlinException) {
        
    }
    
    func onMeetingInitStarted() {
        
    }
    
    func onMeetingRoomConnectionError(errorMessage: String) {
        
    }
    
    func onMeetingRoomDisconnected() {
        
    }
    
    func onMeetingRoomJoinCompleted() {
        self.isJoined = true
    }
    
    func onMeetingRoomJoinFailed(exception: KotlinException) {
        
    }
    
    func onMeetingRoomJoinStarted() {
        
    }
    
    func onMeetingRoomLeaveCompleted() {
        self.isJoined = false
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

extension DyteGroupVideoCallViewModel: DyteChatEventsListener {
    func onChatUpdates(messages: [DyteChatMessage]) {
        
    }
    
    func onNewChatMessage(message: DyteChatMessage) {
        
    }
}

extension DyteGroupVideoCallViewModel: DytePollEventsListener {
    func onNewPoll(poll: DytePollMessage) {
        
    }
    
    func onPollUpdates(pollMessages: [DytePollMessage]) {
        
    }
}

extension DyteGroupVideoCallViewModel: DyteRecordingEventsListener {
    func onMeetingRecordingEnded() {
        
    }
    
    func onMeetingRecordingStarted() {
        
    }
    
    func onMeetingRecordingStateUpdated(state: DyteRecordingState) {
        
    }
    
    func onMeetingRecordingStopError(e: KotlinException) {
        
    }
}

extension DyteGroupVideoCallViewModel: DyteWaitlistEventsListener {
    func onWaitListParticipantAccepted(participant: DyteMeetingParticipant) {
        
    }
    
    func onWaitListParticipantClosed(participant: DyteMeetingParticipant) {
        
    }
    
    func onWaitListParticipantJoined(participant: DyteMeetingParticipant) {
        
    }
    
    func onWaitListParticipantRejected(participant: DyteMeetingParticipant) {
        
    }
}
