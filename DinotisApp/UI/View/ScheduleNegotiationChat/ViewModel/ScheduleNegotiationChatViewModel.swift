//
//  ScheduleNegotiationChatViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 05/10/22.
//

import Foundation
import DinotisData

final class ScheduleNegotiationChatViewModel: ObservableObject {
    
	@Published var endChat: Date
    @Published var textMessage = ""
    @Published var meetingData: UserMeetingData
    
    @Published var state = StateObservable.shared
    
    var backToHome: () -> Void
    
    @Published var route: HomeRouting?

	@Published var token: String

	@Published var count: UInt = 30
    
    init(
		token: String,
        meetingData: UserMeetingData,
		expireDate: Date,
        backToHome: @escaping (() -> Void)
    ) {
		self.token = token
        self.meetingData = meetingData
		self.endChat = expireDate
        self.backToHome = backToHome
    }
    
    func profileImage() -> String {
        if state.userType == 2 {
            return meetingData.participantDetails?.last?.profilePhoto ?? ""
        } else {
            return meetingData.user?.profilePhoto ?? ""
        }
    }
    
    func profileName() -> String {
        if state.userType == 2 {
            return meetingData.participantDetails?.last?.name ?? ""
        } else {
            return meetingData.user?.name ?? ""
        }
    }
    
    func sessionName() -> String {
        return meetingData.title.orEmpty()
    }
    
    func isCanceled() -> Bool {
        guard let data = meetingData.meetingRequest?.isAccepted else { return false }
        
        return !data
        
    }
    
    func isEnded() -> Bool {
        meetingData.endedAt != nil
    }
    
    func isCanceledOrEnded() -> Bool {
        isEnded() || isCanceled()
    }
}
