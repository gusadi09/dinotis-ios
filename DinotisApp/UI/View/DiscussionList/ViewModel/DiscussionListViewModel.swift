//
//  DiscussionListViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 04/10/23.
//

import Combine
import DinotisData
import DinotisDesignSystem
import Foundation
import SwiftUI
import OneSignal

enum DiscussionListType {
    case ongoing
    case completed
}

enum SearchState {
    case initiate
    case success
    case empty
}

final class DiscussionListViewModel: ObservableObject {
    
    private let getInboxChatsUseCase: GetInboxChatsUseCase
    private let stateObservable = StateObservable.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var type: DiscussionListType
    @Published var route: HomeRouting?
    
    var tabSections: [ChatInboxFilter] {
        switch type {
        case .ongoing:
            return [.desc, .asc]
        case .completed:
            return [.desc, .asc]
        }
    }
    @Published var currentSection: ChatInboxFilter = .desc
    
    @Published var isSearching = false
    @Published var searchText = ""
    @Published var debouncedText = ""
    
    @Published var data: [InboxData] = []
    
    @Published var counter = "0"
    
    @Published var isLoading = false
    @Published var isError = false
    @Published var isRefreshFailed = false
    @Published var error = ""
    
    var searchState: SearchState {
        if !searchText.isEmpty && data.isEmpty {
            return .empty
        } else if !searchText.isEmpty && !data.isEmpty {
            return .success
        } else {
            return .initiate
        }
    }
    
    init(
        type: DiscussionListType,
        getInboxChatsUseCase: GetInboxChatsUseCase = GetInboxChatsDefaultUseCase()
    ) {
        self.type = type
        self.getInboxChatsUseCase = getInboxChatsUseCase
    }
    
    func fetchStarted(isRefresh: Bool) {
        DispatchQueue.main.async { [weak self] in
            if !isRefresh {
                self?.isLoading = true
            }
            self?.isError = false
            self?.isRefreshFailed = false
            self?.error = ""
        }
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
    
    func onLoadChats(section: ChatInboxFilter, query: String, isRefresh: Bool = false) {
        Task {
            await getInboxChat(section: section, query: query, isRefresh: isRefresh)
        }
    }
    
    func routeToScheduleNegotiationChat(meet: UserMeetingData, expiredAt: Date) {
        let viewModel = ScheduleNegotiationChatViewModel(meetingData: meet, expireDate: expiredAt, backToHome: {self.route = nil})
        
        DispatchQueue.main.async {[weak self] in
            self?.route = .scheduleNegotiationChat(viewModel: viewModel)
        }
    }
    
    func convertToUserMeet(meet: InboxData) -> UserMeetingData {
        let meet = UserMeetingData(
            id: (meet.meeting?.id).orEmpty(),
            title: (meet.meeting?.title).orEmpty(),
            meetingDescription: (meet.meeting?.description).orEmpty(),
            price: nil,
            startAt: (meet.meeting?.startAt).orCurrentDate(),
            endAt: (meet.meeting?.endAt).orCurrentDate(),
            isPrivate: nil,
            isLiveStreaming: nil,
            slots: nil,
            participants: nil,
            userID: meet.user?.id,
            startedAt: nil,
            endedAt: nil,
            createdAt: nil,
            updatedAt: nil,
            deletedAt: nil,
            bookings: [],
            user: nil,
            participantDetails: [meet.user ?? UserResponse.sample],
            meetingBundleId: nil,
            meetingRequestId: meet.meetingRequestId,
            status: meet.status,
            meetingRequest: MeetingRequestData(
                id: meet.meetingRequestId,
                meetingId: (meet.meeting?.id).orEmpty(),
                message: nil,
                isAccepted: meet.status.orEmpty().contains("accepted"),
                isConfirmed: meet.status.orEmpty().contains("confirmed"),
                userId: nil,
                user: meet.user,
                rateCardId: nil,
                rateCard: nil,
                createdAt: nil,
                updatedAt: nil,
                expiredAt: nil,
                requestAt: nil
            ),
            expiredAt: meet.expiredAt.orCurrentDate(),
            background: [""],
            meetingCollaborations: nil,
            meetingUrls: nil,
            meetingUploads: nil,
            roomSid: meet.conversationSid,
            dyteMeetingId: nil,
            isInspected: nil,
            reviews: nil
        )

        return meet
    }
    
    @MainActor
    func getInboxChat(section: ChatInboxFilter, query: String, isRefresh: Bool) async {
        fetchStarted(isRefresh: isRefresh)
        
        let result = await getInboxChatsUseCase.execute(with: section, by: query)
        
        switch result {
        case .success(let response):
            self.isLoading = false
            
            self.data = response.data ?? []
            self.counter = response.counter ?? "0"
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
            if let error = error as? ErrorResponse {
                
                self?.isError = true
                
                if error.statusCode.orZero() == 401 {
                    self?.error = LocaleText.sessionExpireText
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.error = error.message.orEmpty()
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }
        }
        
    }
    
    func debounceText() {
        $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                withAnimation {
                    self?.debouncedText = text
                }
            })
            .store(in: &cancellables)
    }
}
