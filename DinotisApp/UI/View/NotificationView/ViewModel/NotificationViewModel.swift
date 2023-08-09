//
//  NotificationViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/12/22.
//

import SwiftUI
import Foundation
import DinotisDesignSystem
import Combine
import DinotisData
import OneSignal

final class NotificationViewModel: ObservableObject {
    
    private let notificationListsUseCase: NotificationListsUseCase
    private let approveInvitationUseCase: ApproveCollaborationInvitationUseCase
    private let getCollaborationDetailUseCase: GetCollaborationMeetingUseCase
    private let readAllUseCase: ReadAllUseCase
    private let readByIdUseCase: ReadByIdUseCase
    @Published var stateObservable = StateObservable.shared
    private var cancellables = Set<AnyCancellable>()
    
    var backToRoot: () -> Void
    var backToHome: () -> Void
    
    @Published var route: HomeRouting?
    
    @Published var isRefreshFailed = false
    @Published var isReadLoading = false
    
    @Published var isShowCollabSheet = false
    
    @Published var query = NotificationRequest(take: 15, skip: 0, type: "general", lang: (Locale.current.languageCode).orEmpty())
    
    @Published var alert = AlertAttribute()
    @Published var isShowAlert = false
    @Published var isLoading = false
    @Published var isError = false
    @Published var success = false
    @Published var error: String?
    @Published var nextCursor: Int? = 0
    
    @Published var isLoadingDetail = false
    
    @Published var type = "general"
    
    @Published var resultGeneral = [NotificationData?]()
    @Published var resultTrans = [NotificationData?]()
    
    @Published var detailMeeting: MeetingDetailResponse?
    
    init(
        notificationListsUseCase: NotificationListsUseCase = NotificationListsDefaultUseCase(),
        approveInvitationUseCase: ApproveCollaborationInvitationUseCase = ApproveCollaborationInvitationDefaultUseCase(),
        getCollaborationDetailUseCase: GetCollaborationMeetingUseCase = GetCollaborationMeetingDefaultUseCase(),
        backToRoot: @escaping () -> Void, backToHome: @escaping () -> Void,
        readAllUseCase: ReadAllUseCase = ReadAllDefaultUseCase(),
        readByIdUseCase: ReadByIdUseCase = ReadByIdDefaultUseCase()
    ) {
        self.notificationListsUseCase = notificationListsUseCase
        self.approveInvitationUseCase = approveInvitationUseCase
        self.getCollaborationDetailUseCase = getCollaborationDetailUseCase
        self.backToHome = backToHome
        self.backToRoot = backToRoot
        self.readAllUseCase = readAllUseCase
        self.readByIdUseCase = readByIdUseCase
    }
    
    func onStartFetchDetail() {
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                self?.isLoadingDetail = true
                
                self?.isError = false
                self?.error = nil
                self?.success = false
                self?.isRefreshFailed = false
                self?.isShowAlert = false
                self?.alert = .init(
                    isError: false,
                    title: LocalizableText.attentionText,
                    message: "",
                    primaryButton: .init(text: LocalizableText.closeLabel, action: {}),
                    secondaryButton: nil
                )
            }
        }
    }
    
    @MainActor
    func approveMeeting(_ value: Bool) async {
        withAnimation {
            self.isLoadingDetail = true
            
            self.isError = false
            self.error = nil
            self.success = false
            self.isRefreshFailed = false
            self.isShowAlert = false
            self.alert = .init(
                isError: false,
                title: LocalizableText.attentionText,
                message: "",
                primaryButton: .init(text: LocalizableText.closeLabel, action: {}),
                secondaryButton: nil
            )
        }
        
        let result = await approveInvitationUseCase.execute(value, for: (detailMeeting?.id).orEmpty())
        
        switch result {
        case .success(_):
            self.isShowCollabSheet = false
            self.isLoadingDetail = false
            
            self.isShowAlert = true
            
            if value {
                self.alert = .init(
                    isError: false,
                    title: LocalizableText.acceptedInvitationTitle,
                    message: LocalizableText.acceptedInvitationMessage(name: (self.detailMeeting?.user?.name).orEmpty(), title: (self.detailMeeting?.title).orEmpty()),
                    primaryButton: .init(text: LocalizableText.closeLabel, action: {}),
                    secondaryButton: nil
                )
            } else {
                self.alert = .init(
                    isError: false,
                    title: LocalizableText.declinedInvitationTitle,
                    message: LocalizableText.declinedInvitationMessage(name: (self.detailMeeting?.user?.name).orEmpty(), title: (self.detailMeeting?.title).orEmpty()),
                    primaryButton: .init(text: LocalizableText.closeLabel, action: {}),
                    secondaryButton: nil
                )
            }
        case .failure(let error):
            self.isShowCollabSheet = false
            self.isLoadingDetail = false
            
            if let err = error as? ErrorResponse {
                if err.statusCode.orZero() == 401 {
                    self.alert.isError = true
                    self.alert.message = LocalizableText.alertSessionExpired
                    self.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            self.backToRoot()
                        }
                    )
                } else {
                    self.alert.isError = true
                    self.alert.message = err.message.orEmpty()
                    self.alert.title = LocalizableText.attentionText
                    self.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            
                        }
                    )
                }
            } else {
                self.alert.isError = true
                self.alert.message = error.localizedDescription
                self.alert.title = LocalizableText.attentionText
                self.alert.primaryButton = .init(
                    text: LocalizableText.okText,
                    action: {
                        
                    }
                )
            }
            
            self.isShowAlert = true
        }
    }
    
    @MainActor
    func getDetailCollab(for meetingId: String) async {
        withAnimation {
            self.isLoadingDetail = true
            
            self.isError = false
            self.error = nil
            self.success = false
            self.isRefreshFailed = false
            self.isShowAlert = false
            self.alert = .init(
                isError: false,
                title: LocalizableText.attentionText,
                message: "",
                primaryButton: .init(text: LocalizableText.closeLabel, action: {}),
                secondaryButton: nil
            )
        }
        
        let result = await getCollaborationDetailUseCase.execute(for: meetingId)
        
        switch result {
        case .success(let response):
            self.isLoadingDetail = false
            self.detailMeeting = response
            
        case .failure(let error):
            self.isShowCollabSheet = false
            self.isLoadingDetail = false
            
            if let err = error as? ErrorResponse {
                if err.statusCode.orZero() == 401 {
                    self.alert.isError = true
                    self.alert.message = LocalizableText.alertSessionExpired
                    self.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            self.backToRoot()
                        }
                    )
                } else {
                    self.alert.isError = true
                    self.alert.message = err.message.orEmpty()
                    self.alert.title = LocalizableText.attentionText
                    self.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            
                        }
                    )
                }
            } else {
                self.alert.isError = true
                self.alert.message = error.localizedDescription
                self.alert.title = LocalizableText.attentionText
                self.alert.primaryButton = .init(
                    text: LocalizableText.okText,
                    action: {
                        
                    }
                )
            }
            
            self.isShowAlert = true
        }
    }
    
    func onStartFetch(isRead: Bool) {
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                if isRead {
                    self?.isReadLoading = true
                } else {
                    self?.isLoading = true
                }
                
                self?.isError = false
                self?.error = nil
                self?.success = false
                self?.isRefreshFailed = false
                self?.isShowAlert = false
                self?.alert = .init(
                    isError: false,
                    title: LocalizableText.attentionText,
                    message: "",
                    primaryButton: .init(text: LocalizableText.closeLabel, action: {}),
                    secondaryButton: nil
                )
            }
        }
    }
    
    func handleDefaultError(error: Error, isRead: Bool) {
        DispatchQueue.main.async { [weak self] in
            if isRead {
                self?.isReadLoading = false
            } else {
                self?.isLoading = false
            }
            
            if let error = error as? ErrorResponse {
                
                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                    self?.alert.isError = true
                    self?.alert.message = LocalizableText.alertSessionExpired
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            self?.backToRoot()
                        }
                    )
                    self?.isShowAlert = true
                } else {
                    self?.error = error.message.orEmpty()
                    self?.isError = true
                    self?.alert.message = error.message.orEmpty()
                    self?.alert.isError = true
                    self?.isShowAlert = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
                self?.alert.message = error.localizedDescription
                self?.alert.isError = true
                self?.isShowAlert = true
            }
            
        }
    }
    
    func getNotifications(isReplacing: Bool) async {
        onStartFetch(isRead: false)
        
        let result = await notificationListsUseCase.execute(with: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                withAnimation {
                    self?.isLoading = false
                }
                
                withAnimation {
                    if (self?.query.type).orEmpty() == "general" {
                        if isReplacing {
                            self?.resultGeneral = (success.data ?? []).filter({
                                (
                                    $0?.type
                                ).orEmpty() == "general"
                            })
                        } else {
                            self?.resultGeneral += (success.data ?? []).filter({
                                (
                                    $0?.type
                                ).orEmpty() == "general"
                            })
                            self?.resultGeneral = self?.resultGeneral.unique() ?? []
                        }
                    } else {
                        if isReplacing {
                            self?.resultTrans = (success.data ?? []).filter({
                                (
                                    $0?.type
                                ).orEmpty() == "transaction"
                            })
                        } else {
                            self?.resultTrans += (success.data ?? []).filter({
                                (
                                    $0?.type
                                ).orEmpty() == "transaction"
                            })
                            self?.resultTrans = self?.resultTrans.unique() ?? []
                        }
                    }
                    
                    if success.nextCursor == nil {
                        self?.query.skip = 0
                        self?.query.take = 15
                    }
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure, isRead: false)
        }
    }
    
    func convertToNotificationModel(raw: NotificationData?) -> NotificationCardModel {
        return NotificationCardModel(
            title: raw?.message,
            date: raw?.createdAt,
            detail: raw?.description,
            thumbnail: raw?.thumbnail,
            readAt: raw?.readAt,
            status: raw?.status
        )
    }
    
    func emptyText() -> String {
        type == "general" ? LocalizableText.notificationEmptyTitle : LocalizableText.notificationTransactionEmptyTitle
    }
    
    func descriptionEmptyText() -> String {
        type == "general" ? LocalizableText.notificationEmptyDescription : LocalizableText.notificationTransactionEmptyDescription
    }
    
    func routeToRoot() {
        stateObservable.userType = 0
        stateObservable.isVerified = ""
        stateObservable.refreshToken = ""
        stateObservable.accessToken = ""
        stateObservable.isAnnounceShow = false
        OneSignal.setExternalUserId("")
        backToRoot()
    }
    
    func readAll() async {
        onStartFetch(isRead: true)
        
        let result = await readAllUseCase.execute()
        
        switch result {
        case .success(_):
            DispatchQueue.main.async {[weak self] in
                self?.query.skip = 0
                self?.query.take = 15
                self?.isReadLoading = false
            }
            await self.getNotifications(isReplacing: true)
            
        case .failure(let failure):
            handleDefaultError(error: failure, isRead: true)
        }
    }
    
    func readById(id: String?) async {
        onStartFetch(isRead: true)
        
        let result = await readByIdUseCase.execute(by: id.orEmpty())
        
        switch result {
        case .success(_):
            DispatchQueue.main.async {[weak self] in
                self?.query.skip = 0
                self?.query.take = 15
                self?.isReadLoading = false
            }
            await self.getNotifications(isReplacing: true)
            
        case .failure(let failure):
            handleDefaultError(error: failure, isRead: true)
        }
    }
}
