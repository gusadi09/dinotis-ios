//
//  ScheduleNegotiationChatViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 05/10/22.
//

import DinotisData
import Foundation
import OneSignal

enum ChatNegotiationAlert {
    case error
    case refreshFailed
}

final class ScheduleNegotiationChatViewModel: ObservableObject {
    private let conversationTokenUseCase: ConversationTokenUseCase
    private let stateObservable = StateObservable.shared
    
	@Published var endChat: Date
    @Published var textMessage = ""
    @Published var meetingData: UserMeetingData
    
    @Published var state = StateObservable.shared
    
    var backToHome: () -> Void
    
    @Published var route: HomeRouting?

    @Published var tokenConversation = ""

	@Published var count: UInt = 30
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var error: String?
    @Published var typeAlert: ChatNegotiationAlert = .error
    @Published var isShowAlert = false
    @Published var isRefreshFailed = false
    
    init(
        meetingData: UserMeetingData,
		expireDate: Date,
        conversationTokenUseCase: ConversationTokenUseCase = ConversationTokenDefaultUseCase(),
        backToHome: @escaping (() -> Void)
    ) {
        self.meetingData = meetingData
		self.endChat = expireDate
        self.backToHome = backToHome
        self.conversationTokenUseCase = conversationTokenUseCase
    }
    
    func routeToRoot() {
        NavigationUtil.popToRootView()
        self.stateObservable.userType = 0
        self.stateObservable.isVerified = ""
        self.stateObservable.refreshToken = ""
        self.stateObservable.accessToken = ""
        self.stateObservable.isAnnounceShow = false
        OneSignal.setExternalUserId("")
    }
    
    func alertTitle() -> String {
        switch typeAlert {
        case .error:
            return LocaleText.errorText
        case .refreshFailed:
            return LocaleText.attention
        }
    }
    
    func alertContent() -> String {
        switch typeAlert {
        case .error:
            return error.orEmpty()
        case .refreshFailed:
            return LocaleText.sessionExpireText
        }
    }
    
    func alertButtonText() -> String {
        switch typeAlert {
        case .error:
            return LocaleText.returnText
        case .refreshFailed:
            return LocaleText.returnText
        }
    }
    
    func alertAction() {
        switch typeAlert {
        case .error:
            break
        case .refreshFailed:
            routeToRoot()
        }
    }
    
    @MainActor
    func getConversationToken(id: String) async {
        onStartFetchDetail()

        let result = await conversationTokenUseCase.execute(with: id)

        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.tokenConversation = success.token.orEmpty()
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func onStartFetchDetail() {
        DispatchQueue.main.async { [weak self] in
            self?.error = nil
            self?.isError = false
            self?.isShowAlert = false
            self?.isLoading = true
            self?.isRefreshFailed = false
        }
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isShowAlert = true
            
            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()
                
                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                    self?.typeAlert = .refreshFailed
                } else {
                    self?.isError = true
                    self?.typeAlert = .error
                }
            } else {
                self?.isError = true
                self?.typeAlert = .error
                self?.error = error.localizedDescription
            }
        }
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
