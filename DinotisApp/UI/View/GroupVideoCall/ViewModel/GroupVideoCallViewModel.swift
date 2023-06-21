//
//  GroupVideoCallViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/23.
//

import Foundation
import DyteiOSCore

final class GroupVideoCallViewModel: ObservableObject {
    var backToRoot: () -> Void
    var backToHome: () -> Void
    
    let meeting = DyteiOSClientBuilder().build()
    
    let meetingInfo = DyteMeetingInfoV2(
        authToken: "authToken",
        enableAudio: true,
        enableVideo: true,
        baseUrl: "https://api.cluster.dyte.in/v2"
    )
    
    init(
        backToRoot: @escaping () -> Void,
        backToHome: @escaping () -> Void
    ) {
        self.backToHome = backToHome
        self.backToRoot = backToRoot
        
        meeting.addMeetingRoomEventsListener(meetingRoomEventsListener: self)
        meeting.addParticipantEventsListener(participantEventsListener: self)
        meeting.addSelfEventsListener(selfEventsListener: self)
        meeting.addParticipantEventsListener(participantEventsListener: self)
        meeting.addChatEventsListener(chatEventsListener: self)
        meeting.addPollEventsListener(pollEventsListener: self)
        meeting.addRecordingEventsListener(recordingEventsListener: self)
        meeting.addWaitlistEventsListener(waitlistEventsListener: self)
    }
    
    
}

extension GroupVideoCallViewModel: DyteMeetingRoomEventsListener {
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
        
    }
    
    func onMeetingRoomJoinFailed(exception: KotlinException) {
        
    }
    
    func onMeetingRoomJoinStarted() {
        
    }
    
    func onMeetingRoomLeaveCompleted() {
        
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

extension GroupVideoCallViewModel: DyteSelfEventsListener {
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
