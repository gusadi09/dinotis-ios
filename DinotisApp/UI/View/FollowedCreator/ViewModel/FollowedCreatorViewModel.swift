//
//  FollowedCreatorViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/12/22.
//

import Foundation
import UIKit
import SwiftUI
import DinotisDesignSystem
import Combine
import DinotisData
import OneSignal

final class FollowedCreatorViewModel: ObservableObject {
    
    private let followedCreatorUseCase: FollowedCreatorUseCase
    private let getSubscriptionsUseCase: GetSubscriptionsUseCase
    private var stateObservable = StateObservable.shared
    private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
    
    var backToHome: () -> Void
    
    @Published var isLoadingFollowing = false
    @Published var isLoadingSubs = false
    @Published var isError = false
    @Published var error: String?
    
    @Published var isRefreshFailed = false
    
    @Published var isShowAlert = false
    @Published var alert = AlertAttribute()
    
    @Published var route: HomeRouting?
    
    @Published var query = GeneralParameterRequest(skip: 0, take: 5)
    @Published var nextCursosr: Int?
    @Published var subsQuery = GeneralParameterRequest(skip: 0, take: 5, sort: .asc)
    @Published var subsNextCursor: Int?
    
    @Published var talentData = [TalentData]()
    @Published var subscriptionData = [SubscriptionResponse]()
    
    @Published var currentTab = 0
    
    init(
        followedCreatorUseCase: FollowedCreatorUseCase = FollowedCreatorDefaultUseCase(),
        getSubscriptionsUseCase: GetSubscriptionsUseCase = GetSubscriptionsDefaultUseCase(),
        backToHome: @escaping () -> Void
    ) {
        self.followedCreatorUseCase = followedCreatorUseCase
        self.getSubscriptionsUseCase = getSubscriptionsUseCase
        self.backToHome = backToHome
    }
    
    func openWhatsApp() {
        if let waurl = URL(string: "https://wa.me/6281318506068") {
            if UIApplication.shared.canOpenURL(waurl) {
                UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
            }
        }
    }
    
    func convertToStringProfession(_ professions: [String]?) -> String {
        (professions ?? []).joined(separator: ", ")
    }
    
    func convertToCardModel(with data: TalentData) -> CreatorCardModel {
        return CreatorCardModel(
            name: data.name.orEmpty(),
            isVerified: data.isVerified ?? false,
            professions: convertToStringProfession(data.stringProfessions),
            photo: data.profilePhoto.orEmpty()
        )
    }
    
    func onStartRequest() {
        DispatchQueue.main.async {[weak self] in
            self?.isLoadingFollowing = true
            self?.isError = false
            self?.error = nil
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
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoadingFollowing = false
            
            if let error = error as? ErrorResponse {
                
                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                    self?.alert.message = LocalizableText.alertSessionExpired
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            NavigationUtil.popToRootView()
                            self?.stateObservable.userType = 0
                            self?.stateObservable.isVerified = ""
                            self?.stateObservable.refreshToken = ""
                            self?.stateObservable.accessToken = ""
                            self?.stateObservable.isAnnounceShow = false
                            OneSignal.setExternalUserId("")
                        }
                    )
                } else {
                    self?.error = error.message.orEmpty()
                    self?.isError = true
                    self?.alert.message = error.message.orEmpty()
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
                self?.alert.message = error.localizedDescription
            }
            self?.alert.isError = true
            self?.isShowAlert = true
        }
    }
    
    @MainActor
    func getFollowedCreator(isMore: Bool = false) async {
        onStartRequest()
        if !isMore {
            self.query = .init(skip: 0, take: 5)
        }
        
        let result = await followedCreatorUseCase.execute(with: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoadingFollowing = false
                
                withAnimation {
                    self?.talentData += success.data ?? []
                    self?.talentData = (self?.talentData ?? []).unique()
                    self?.nextCursosr = success.nextCursor
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    @MainActor
    func getSubscriptionList(isMore: Bool = false) async {
        self.isLoadingSubs = true
        
        if !isMore {
            subsQuery = .init(skip: 0, take: 15, sort: .asc)
        }
        
        let result = await getSubscriptionsUseCase.execute(param: subsQuery)
        
        switch result {
        case .success(let response):
            self.isLoadingSubs = false
            
            withAnimation {
                if isMore {
                    self.subscriptionData += response.data ?? []
                } else {
                    self.subscriptionData = response.data ?? []
                }
            }
            
            self.subscriptionData = self.subscriptionData.unique()
            self.subsNextCursor = response.nextCursor
        case .failure(let error):
            self.isLoadingSubs = false
            handleDefaultError(error: error)
        }
    }
    
    func use(for scrollView: UIScrollView, onValueChanged: @escaping ((UIRefreshControl) -> Void)) {
        DispatchQueue.main.async {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(
                self,
                action: #selector(self.onValueChangedAction),
                for: .valueChanged
            )
            scrollView.refreshControl = refreshControl
            self.onValueChanged = onValueChanged
        }
        
    }
    
    @objc private func onValueChangedAction(sender: UIRefreshControl) {
        Task.init {
            self.onValueChanged?(sender)
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
    
    func onRefresh() async {
        await getFollowedCreator()
    }
    
    func routeToTalentDetail(username: String) {
        let viewModel = TalentProfileDetailViewModel(backToHome: self.backToHome, username: username)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .talentProfileDetail(viewModel: viewModel)
        }
    }
}
