//
//  UserHomeViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 24/02/22.
//

import Foundation
import Combine
import UIKit
import SwiftUI
import OneSignal
import DinotisData
import DinotisDesignSystem

enum AudienceHomeLoadType {
    case firstBanner
    case secondBanner
    case homeContent
    case privateFeature
    case groupFeature
    case talentList
    case profession
    case originalSection
    case none
}

final class UserHomeViewModel: NSObject, ObservableObject {
    
    private lazy var stateObservable = StateObservable.shared
    private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
    private let getUserUseCase: GetUserUseCase
    private let counterUseCase: GetCounterUseCase
    private let getSearchedTalentUseCase: GetSearchedTalentUseCase
    private let getCrowdedTalentUseCase: GetCrowdedTalentUseCase
    
    private let professionListUseCase: ProfessionListUseCase
    private let categoryListUseCase: CategoryListUseCase
    private let getOriginalUseCase: GetOriginalContentUseCase
    private let getAnnouncementUseCase: GetAnnouncementUseCase
    private let getLatestNoticeUseCase: GetLatestNoticeUseCase
    private let getPrivateUseCase: GetPrivateFeatureUseCase
    private let getGroupUseCase: GetGroupFeatureUseCase
    private let coinRepository: CoinRepository
    private let getDynamicContentUseCase: GetDynamicHomeUseCase
    private let getFirstBannerUseCase: GetFirstBannerUseCase
    private let getSecondBannerUseCase: GetSecondBannerUseCase

    @Published var latestNotice = [LatestNoticeData]()
    @Published var selectedCategory = ""
    @Published var selectedCategoryId = 0
    @Published var selectedProfession = 0
    @Published var currentPage = 0

	@Published var statusCode = 0
    
    @Published var route: HomeRouting?
    
    @Published var username: String?
    @Published var showingPasswordAlert = false
    
    @Published var isLoadingFirstBanner = false
    @Published var isLoadingSecondBanner = false
    @Published var isLoadingHomeContent = false
    @Published var isLoadingPrivateFeature = false
    @Published var isLoadingGroupFeature = false
    @Published var isLoadingTalentList = false
    @Published var isLoadingProfession = false
    @Published var isLoadingOriginalSection = false
    
    @Published var userData: UserResponse?
    
    @Published var profession = [ProfessionElement]()
    @Published var privateScheduleContent = [UserMeetingData]()
    @Published var groupScheduleContent = [UserMeetingData]()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isError: Bool = false
    @Published var error: String?
    @Published var success: Bool = false
  
  @Published var isShowAlert = false
  @Published var alert = AlertAttribute()
    
    @Published var homeContent = [DynamicHomeData]()
    @Published var originalSectionContent: OriginalSectionResponse?
    
    @Published var isRefreshFailed = false
    
    @Published var takeItem = 10
    
    @Published var skip = 0
    
    @Published var nextCursor: Int? = 0
    
    @Published var photoProfile: String?
    
    @Published var nameOfUser: String?
    
    @Published var firstBanner = [BannerData]()
    @Published var selectedFirstBanner: Int?
    @Published var firstBannerContents = [BannerImage]()
    
    @Published var secondBanner = [BannerData]()
    @Published var secondBannerContents = [BannerImage]()
    
    @Published var categoryData: CategoriesResponse?
    
    @Published var trendingData = [TalentWithProfessionData]()
    
    @Published var reccomendData = [Talent]()
    
    @Published var isSearchLoading = false
    
    @Published var searchResult = [TalentWithProfessionData]()

    @Published var announceData = [AnnouncementData]()
    @Published var announceIndex = 0
    
    @Published var hasNewNotif = false
    
    init(
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        professionListUseCase: ProfessionListUseCase = ProfessionListDefaultUseCase(),
        categoryListUseCase: CategoryListUseCase = CategoryListDefaultUseCase(),
        getSearchedTalentUseCase: GetSearchedTalentUseCase = GetSearchedTalentDefaultUseCase(),
        getCrowdedTalentUseCase: GetCrowdedTalentUseCase = GetCrowdedTalentDefaultUseCase(),
        getOriginalUseCase: GetOriginalContentUseCase = GetOriginalContentDefaultUseCase(),
        coinRepository: CoinRepository = CoinDefaultRepository(),
        counterUseCase: GetCounterUseCase = GetCounterDefaultUseCase(),
        getAnnouncementUseCase: GetAnnouncementUseCase = GetAnnouncementDefaultUseCase(),
        getLatestNoticeUseCase: GetLatestNoticeUseCase = GetLatestNoticeDefaultUseCase(),
        getPrivateUseCase: GetPrivateFeatureUseCase = GetPrivateFeatureDefaultUseCase(),
        getGroupUseCase: GetGroupFeatureUseCase = GetGroupFeatureDefaultUseCase(),
        getDynamicContentUseCase: GetDynamicHomeUseCase = GetDynamicHomeDefaultUseCase(),
        getFirstBannerUseCase: GetFirstBannerUseCase = GetFirstBannerDefaultUseCase(),
        getSecondBannerUseCase: GetSecondBannerUseCase = GetSecondBannerDefaultUseCase()
    ) {
        self.getUserUseCase = getUserUseCase
        self.professionListUseCase = professionListUseCase
        self.categoryListUseCase = categoryListUseCase
        self.getSearchedTalentUseCase = getSearchedTalentUseCase
        self.getCrowdedTalentUseCase = getCrowdedTalentUseCase
        self.getOriginalUseCase = getOriginalUseCase
        self.coinRepository = coinRepository
        self.counterUseCase = counterUseCase
        self.getAnnouncementUseCase = getAnnouncementUseCase
        self.getLatestNoticeUseCase = getLatestNoticeUseCase
        self.getPrivateUseCase = getPrivateUseCase
        self.getGroupUseCase = getGroupUseCase
        self.getDynamicContentUseCase = getDynamicContentUseCase
        self.getFirstBannerUseCase = getFirstBannerUseCase
        self.getSecondBannerUseCase = getSecondBannerUseCase
    }

    func openWhatsApp() {
        if let waurl = URL(string: "https://wa.me/6281318506068") {
            if UIApplication.shared.canOpenURL(waurl) {
                UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
            }
        }
    }

	func talentArray() -> [TalentWithProfessionData] {
		return self.searchResult.filter({ value in
			if self.selectedProfession != 0 {
				return value.professions?.contains(where: { value in
					(value.profession?.id).orZero() == self.selectedProfession
				}) ?? false
			} else {
				return true
			}
		})
	}
    
    func errorText() -> String {
        error.orEmpty()
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
    
    func onGetCount() {
        Task {
            await self.getCounter()
        }
    }
    
    func onGetUser() {
        Task {
            await self.getUsers()
        }
    }
    
    func onGetAllProfession() {
        Task {
            await self.getAllProfession()
        }
    }
    
    func onGetOriginal() {
        Task {
            await self.getOriginalSection()
        }
    }
    
    func onGetLatest() {
        Task {
            await self.getLatestNotice()
        }
    }
    
    func onGetPrivate() {
        Task {
            await self.getPrivateFeatureCall()
        }
    }
    
    func onGetGroup() {
        Task {
            await self.getGroupFeatureCall()
        }
    }
    
    func onGetHomeContent() {
        Task {
            await self.getHomeContent()
        }
    }
    
    func onGetFirstBanner(geo: GeometryProxy) {
        Task {
            await self.getFirstBanner(geo: geo)
        }
    }
    
    func onGetSecondBanner(geo: GeometryProxy) {
        Task {
            await self.getSecondBanner(geo: geo)
        }
    }
    
    func onGetSearchedTalent() {
        Task {
            await self.getAllTalents()
        }
    }
    
    func onScreenAppear(geo: GeometryProxy) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onGetCount()
            guard !self.isRefreshFailed else { return }
            self.onGetUser()
            self.onGetGroup()
            self.onGetLatest()
            self.onGetPrivate()
            self.onGetOriginal()
            self.onGetHomeContent()
            self.onGetAllProfession()
            self.onGetFirstBanner(geo: geo)
            self.onGetSecondBanner(geo: geo)
            self.takeItem = 10
            self.selectedCategoryId = 0
            self.selectedCategory = ""
            self.onGetSearchedTalent()
        }
    }
    
    func routeBack() {
        if statusCode == 401 {
            NavigationUtil.popToRootView()
            self.stateObservable.userType = 0
            self.stateObservable.isVerified = ""
            self.stateObservable.refreshToken = ""
            self.stateObservable.accessToken = ""
            self.stateObservable.isAnnounceShow = false
            OneSignal.setExternalUserId("")
        }
    }
    
    func routeToProfile() {
        let viewModel = ProfileViewModel(backToHome: { self.route = nil })
        
        DispatchQueue.main.async { [weak self] in
            if self?.stateObservable.userType == 2 {
                self?.route = .talentProfile(viewModel: viewModel)
            } else {
                self?.route = .userProfile(viewModel: viewModel)
            }
        }
    }
    
    func routeToTalentProfile() {
        let viewModel = TalentProfileDetailViewModel(backToHome: {self.route = nil}, username: self.username.orEmpty())
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .talentProfileDetail(viewModel: viewModel)
        }
    }
    
    func routeToScheduleList() {
        let viewModel = ScheduleDetailViewModel(isActiveBooking: true, bookingId: stateObservable.bookId, backToHome: {self.route = nil}, isDirectToHome: false)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .userScheduleDetail(viewModel: viewModel)
        }
    }
    
    func onStartedFetch(type: AudienceHomeLoadType) {
        DispatchQueue.main.async {[weak self] in
            self?.isError = false
            
            self?.error = nil
            self?.success = false
          self?.isShowAlert = false
          self?.alert = .init(
            isError: false,
            title: LocalizableText.attentionText,
            message: "",
            primaryButton: .init(
              text: LocalizableText.closeLabel,
              action: {}
            ),
            secondaryButton: nil
          )
            
            switch type {
            case .firstBanner:
                self?.isLoadingFirstBanner = true
            case .secondBanner:
                self?.isLoadingSecondBanner = true
            case .homeContent:
                self?.isLoadingHomeContent = true
            case .privateFeature:
                self?.isLoadingPrivateFeature = true
            case .groupFeature:
                self?.isLoadingGroupFeature = true
            case .talentList:
                self?.isLoadingTalentList = true
            case .profession:
                self?.isLoadingProfession = true
            case .originalSection:
                self?.isLoadingOriginalSection = true
            case .none:
                break
            }
        }
    }
    
    func onStartedFetchSearch() {
        DispatchQueue.main.async {[weak self] in
            self?.isError = false
            self?.isSearchLoading = true
            self?.error = nil
            self?.success = false
        }
    }
    
    func handleDefaultErrorTalentLoad(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isSearchLoading = false
            
            if let error = error as? ErrorResponse {
                
                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                    self?.alert.isError = true
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
                            OneSignal.setExternalUserId("") }
                    )
                    self?.isShowAlert = true
                } else {
                    self?.error = error.message.orEmpty()
                    self?.isError = true
                    self?.alert.isError = true
                    self?.alert.message = error.message.orEmpty()
                    self?.isShowAlert = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
                self?.alert.isError = true
                self?.alert.message = error.localizedDescription
                self?.isShowAlert = true
            }
            
        }
    }
    
    func getAllTalents() async {
        onStartedFetchSearch()
        
        let query = TalentsRequest(
            query: "",
            skip: takeItem-10,
            take: takeItem,
            profession: nil,
            professionCategory: nil
        )
        
        let result = await getSearchedTalentUseCase.execute(query: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isSearchLoading = false
                for items in success.data ?? [] {
                    self?.searchResult.append(items)
                }
                
                let temp = self?.searchResult.unique()
                
                self?.searchResult = temp ?? []
                
                self?.nextCursor = success.nextCursor
            }
        case .failure(let failure):
            handleDefaultErrorTalentLoad(error: failure)
        }
    }
    
    func getCounter() async {
        onStartedFetch(type: .none)
        
        let result = await counterUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.hasNewNotif = success.unreadNotificationCount.orZero() > 0
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .none)
        }
    }
    
    func getAllProfession() async {
        onStartedFetch(type: .profession)
        
        let result = await professionListUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoadingProfession = false
                self?.profession = success.data ?? []
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .profession)
        }
    }

    func getOriginalSection() async {
        onStartedFetch(type: .originalSection)
        
        let result = await getOriginalUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoadingOriginalSection = false
                self?.originalSectionContent = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .originalSection)
        }
    }

    func getLatestNotice() async {
        onStartedFetch(type: .none)
        
        let result = await getLatestNoticeUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.latestNotice = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .none)
        }
    }
    
    func getPrivateFeatureCall() async {
        onStartedFetch(type: .privateFeature)

        DispatchQueue.main.async {
            self.privateScheduleContent = []
        }
        
        let result = await getPrivateUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoadingPrivateFeature = false
                self?.privateScheduleContent = success.data ?? []
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .privateFeature)
        }
    }

    func getGroupFeatureCall() async {
        onStartedFetch(type: .groupFeature)

        DispatchQueue.main.async {
            self.groupScheduleContent = []
        }
        
        let result = await getGroupUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoadingGroupFeature = false
                self?.groupScheduleContent = success.data ?? []
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .groupFeature)
        }
    }
    
    func getHomeContent() async {
        onStartedFetch(type: .homeContent)

        DispatchQueue.main.async {
            self.homeContent = []
        }
        
        let result = await getDynamicContentUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoadingHomeContent = false
                self?.homeContent = success.data ?? []
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .homeContent)
        }
    }
    
    func getSecondBanner(geo: GeometryProxy) async {
        onStartedFetch(type: .secondBanner)

        DispatchQueue.main.async {[self] in
            secondBannerContents = []
        }
        
        let result = await getSecondBannerUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoadingSecondBanner = false
                
                self?.secondBanner = success.data ?? []

                var temp = [BannerImage]()
                
                for item in success.data ?? [] {
                    temp.append(
                        BannerImage(
                            content: item,
                            action: {
                                guard let url = URL(string: item.url.orEmpty()) else { return }
                                UIApplication.shared.open(url)
                            },
                            geo: geo
                        )
                    )
                }

                self?.secondBannerContents = temp
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .secondBanner)
        }
    }
    
    func getFirstBanner(geo: GeometryProxy) async {
        onStartedFetch(type: .firstBanner)

        DispatchQueue.main.async { [self] in
            firstBannerContents = []
        }
        
        let result = await getFirstBannerUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoadingFirstBanner = false
                
                self?.firstBanner = success.data ?? []
                
                self?.selectedFirstBanner = (success.data?.first?.id).orZero()

                var temp = [BannerImage]()

                for item in success.data ?? [] {
                    temp.append(
                        BannerImage(
                            content: item,
                            action: {
                                guard let url = URL(string: item.url.orEmpty()) else { return }
                                UIApplication.shared.open(url)
                            },
                            geo: geo
                        )
                    )
                }

                self?.firstBannerContents = temp
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .firstBanner)
        }
    }
    
    func handleDefaultError(error: Error, type: AudienceHomeLoadType) {
        DispatchQueue.main.async { [weak self] in
            switch type {
            case .firstBanner:
                self?.isLoadingFirstBanner = false
            case .secondBanner:
                self?.isLoadingSecondBanner = false
            case .homeContent:
                self?.isLoadingHomeContent = false
            case .privateFeature:
                self?.isLoadingPrivateFeature = false
            case .groupFeature:
                self?.isLoadingGroupFeature = false
            case .talentList:
                self?.isLoadingTalentList = false
            case .profession:
                self?.isLoadingProfession = false
            case .originalSection:
                self?.isLoadingOriginalSection = false
            case .none:
                break
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
                        NavigationUtil.popToRootView()
                        self?.stateObservable.userType = 0
                        self?.stateObservable.isVerified = ""
                        self?.stateObservable.refreshToken = ""
                        self?.stateObservable.accessToken = ""
                        self?.stateObservable.isAnnounceShow = false
                        OneSignal.setExternalUserId("") }
                  )
                  self?.isShowAlert = true
                } else {
                    self?.error = error.message.orEmpty()
                    self?.isError = true
                  self?.alert.isError = true
                  self?.alert.message = error.message.orEmpty()
                  self?.isShowAlert = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
              self?.alert.isError = true
              self?.alert.message = error.localizedDescription
              self?.isShowAlert = true
            }

        }
    }
    
    func getUsers() async {
        onStartedFetch(type: .none)
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                
                self?.userData = success
                self?.nameOfUser = success.name
                self?.photoProfile = success.profilePhoto
                self?.stateObservable.userId = success.id.orEmpty()
                OneSignal.setExternalUserId(success.id.orEmpty())
                OneSignal.sendTag("isTalent", value: "false")
                
                withAnimation {
                    self?.showingPasswordAlert = !(success.isPasswordFilled ?? false)
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .none)
        }
    }
    
    func getTrendingTalent() async {
        onStartedFetch(type: .talentList)
        
        let query = TalentsRequest(query: "", skip: 0, take: 10)
        
        let result = await getCrowdedTalentUseCase.execute(query: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoadingTalentList = false
                self?.trendingData = success.data ?? []
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .talentList)
        }
    }

    func getAnnouncement() async {
        onStartedFetch(type: .none)

        let result = await getAnnouncementUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.announceData = success.data ?? []
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .none)
        }
    }
    
    func onStartRefresh(type: AudienceHomeLoadType) {
        DispatchQueue.main.async { [weak self] in
            self?.isRefreshFailed = false
            switch type {
            case .firstBanner:
                self?.isLoadingFirstBanner = true
            case .secondBanner:
                self?.isLoadingSecondBanner = true
            case .homeContent:
                self?.isLoadingHomeContent = true
            case .privateFeature:
                self?.isLoadingPrivateFeature = true
            case .groupFeature:
                self?.isLoadingGroupFeature = true
            case .talentList:
                self?.isLoadingTalentList = true
            case .profession:
                self?.isLoadingProfession = true
            case .originalSection:
                self?.isLoadingOriginalSection = true
            case .none:
                break
            }
            self?.success = false
            self?.error = nil
            self?.isError = false
        }
    }
    
    func routeToSearch() {
        let viewModel = SearchTalentViewModel(
            backToHome: {self.route = nil}
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .searchTalent(viewModel: viewModel)
        }
    }

	func routeToNotification() {
		let viewModel = NotificationViewModel(backToHome: { self.route = nil })

		DispatchQueue.main.async { [weak self] in
			self?.route = .notification(viewModel: viewModel)
		}
	}
}
