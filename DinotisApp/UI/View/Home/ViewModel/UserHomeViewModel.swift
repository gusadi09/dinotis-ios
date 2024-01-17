//
//  UserHomeViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 24/02/22.
//

import Combine
import DinotisData
import DinotisDesignSystem
import OneSignal
import StoreKit
import SwiftUI
import UIKit

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
    case followedCreator
    case followUnfollow(Int)
    case rateCard
    case allSession
    case recentCreator
    case popularCreator
    case checkPromoCode
    case coinPay
    case freePayment
    case verifyCoin
    case extraFee
    case followingSession(Bool)
}

enum AudienceHomeTab {
    case forYou
    case following
}

enum SessionType {
    case privateSession
    case groupSession
    case exclusiveVideo
}

final class UserHomeViewModel: NSObject, ObservableObject {
    
    private lazy var stateObservable = StateObservable.shared
    private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
    
    private let followedCreatorUseCase: FollowedCreatorUseCase
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
    private let followUseCase: FollowCreatorUseCase
    private let unfollowUseCase: UnfollowCreatorUseCase
    private let getRateCardListUseCase: GetRateCardListUseCase
    private let getAllSessionUseCase: GetAllSessionUseCase
    private let getRecentCreatorListUseCase: GetHomeCreatorListUseCase
    private let getPopularCreatorUseCase: GetCrowdedTalentUseCase
    private let promoCodeCheckingUseCase: PromoCodeCheckingUseCase
    private let coinPaymentUseCase: CoinPaymentUseCase
    private let bookingPaymentUseCase: BookingPaymentUseCase
    private let coinVerificationUseCase: CoinVerificationUseCase
    private let extraFeeUseCase: GetExtraFeeUseCase
    private let getVideoListUseCase: GetFeatureVideoUseCase
    
    @Published var currentMainTab = AudienceHomeTab.forYou

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
    @Published var isLoadingFollowedCreator = false
    @Published var isLoadingRateCard = false
    @Published var isLoadingAllSession = false
    @Published var isLoadingRecentCreator = false
    @Published var isLoadingPopularCreator = false
    @Published var isLoadingCoinPay = false
    @Published var isLoadingTrx = false
    @Published var isLoadingFreePayment = false
    @Published var isLoadingExtraFee = false
    @Published var isLoadingFollowingSession = false
    @Published var isLoadMoreFollowingSession = false
    
    @Published var userData: UserResponse?
    
    @Published var profession = [ProfessionElement]()
    
    @Published var sessionTab: SessionType = .groupSession
    @Published var privateScheduleContent = [UserMeetingData]()
    @Published var groupScheduleContent = [UserMeetingData]()
    
    var sessionContent: [UserMeetingData] {
        switch sessionTab {
        case .privateSession:
            privateScheduleContent
        default:
            groupScheduleContent
        }
    }
    
    @Published var followingGroupParam = FollowingContentRequest(followed: true)
    @Published var followingGroupNextCursor: Int?
    @Published var followingPrivateParam = FollowingContentRequest(followed: true)
    @Published var followingPrivateNextCursor: Int?
    @Published var followingVideoParam = FollowingContentRequest(followed: true)
    @Published var followingVideoNextCursor: Int?
    
    @Published var followingSessionTab: SessionType = .groupSession
    @Published var followingSessionSections: [SessionType] = [.groupSession, .privateSession, .exclusiveVideo]
    @Published var followingPrivate = [UserMeetingData]()
    @Published var followingGroup = [UserMeetingData]()
    @Published var followingVideos = [MineVideoData]()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isError: Bool = false
    @Published var error: String?
    @Published var success: Bool = false
  
    @Published var isShowAlert = false
    @Published var alert = AlertAttribute()

    @Published var isShowSessionDetail = false
    @Published var isDescComplete = false
    @Published var isShowCollabList = false
    
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
    @Published var followedCreator = [TalentData]()
    
    @Published var rateCardList = [RateCardResponse]()
    @Published var allSessionData = [MeetingDetailResponse]()
    @Published var recentCreatorList = [TalentWithProfessionData]()
    @Published var popularCreatorList = [TalentWithProfessionData]()
    
    @Published var isSearchLoading = false
    
    @Published var searchResult = [TalentWithProfessionData]()

    @Published var announceData = [AnnouncementData]()
    @Published var announceIndex = 0
    
    @Published var hasNewNotif = false
    @Published var hasNewNotifInbox = false
    
    @Published var notificationInboxBadgeCountStr = ""
    @Published var notificationBadgeCountStr = ""
    
    @Published var sessionCard = MeetingDetailResponse(user: nil, background: [""], meetingCollaborations: nil, meetingUrls: nil, meetingUploads: nil, isCollaborationAlreadyConfirmed: nil, isAlreadyBooked: nil)
    
    @Published var isTransactionSucceed = false
    @Published var isFreeBookingSucceed = false
    
    @Published var myProducts = [SKProduct]()
    
    @Published var productIDs = [
        "dinotisapp.coin01",
        "dinotisapp.coin02",
        "dinotisapp.coin03",
        "dinotisapp.coin04",
        "dinotisapp.coin05",
        "dinotisapp.coin06",
        "dinotisapp.coin07",
        "dinotisapp.coin08"
    ]
    
    var request: SKProductsRequest?
    @Published var productSelected: SKProduct? = nil
    @Published var transactionState: SKPaymentTransactionState?
    
    @Published var extraFee = 0
    @Published var totalPayment = 0
    
    @Published var promoCode = ""
    @Published var promoCodeError = false
    @Published var promoCodeSuccess = false
    @Published var promoCodeData: PromoCodeResponse?
    @Published var promoCodeTextArray = [String]()
    @Published var isPromoCodeLoading = false
    
    @Published var isShowPaymentOption = false
    @Published var isShowCoinPayment = false
    @Published var isShowAddCoin = false
    @Published var freeTrans = false
    
    @Published var isFollowed: [Bool] = []
    @Published var isLoadingFollowUnfollow: [Bool] = []
    
    @Published var rateCardImgOpacity: Double = 1.0
    var imgOpacity1: Double {
        1 + rateCardImgOpacity
    }
    
    @Published var creatorImgOpacity: Double = 1.0
    var imgOpacity2: Double {
        1 + creatorImgOpacity
    }
    
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
        getSecondBannerUseCase: GetSecondBannerUseCase = GetSecondBannerDefaultUseCase(),
        followedCreatorUseCase: FollowedCreatorUseCase = FollowedCreatorDefaultUseCase(),
        followUseCase: FollowCreatorUseCase = FollowCreatorDefaultUseCase(),
        unfollowUseCase: UnfollowCreatorUseCase = UnfollowCreatorDefaultUseCase(),
        getRateCardListUseCase: GetRateCardListUseCase = GetRateCardListDefaultUseCase(),
        getAllSessionUseCase: GetAllSessionUseCase = GetAllSessionDefaultUseCase(),
        getRecentCreatorListUseCase: GetHomeCreatorListUseCase = GetHomeCreatorListDefaultUseCas(),
        getPopularCreatorUseCase: GetCrowdedTalentUseCase = GetCrowdedTalentDefaultUseCase(),
        promoCodeCheckingUseCase: PromoCodeCheckingUseCase = PromoCodeCheckingDefaultUseCase(),
        coinPaymentUseCase: CoinPaymentUseCase = CoinPaymentDefaultUseCase(),
        bookingPaymentUseCase: BookingPaymentUseCase = BookingPaymentDefaultUseCase(),
        coinVerificationUseCase: CoinVerificationUseCase = CoinVerificationDefaultUseCase(),
        extraFeeUseCase: GetExtraFeeUseCase = GetExtraFeeDefaultUseCase(),
        getVideoListUseCase: GetFeatureVideoUseCase = GetFeatureVideoDefaultUseCase()
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
        self.followedCreatorUseCase = followedCreatorUseCase
        self.followUseCase = followUseCase
        self.unfollowUseCase = unfollowUseCase
        self.getRateCardListUseCase = getRateCardListUseCase
        self.getAllSessionUseCase = getAllSessionUseCase
        self.getRecentCreatorListUseCase = getRecentCreatorListUseCase
        self.getPopularCreatorUseCase = getPopularCreatorUseCase
        self.promoCodeCheckingUseCase = promoCodeCheckingUseCase
        self.coinPaymentUseCase = coinPaymentUseCase
        self.bookingPaymentUseCase = bookingPaymentUseCase
        self.coinVerificationUseCase = coinVerificationUseCase
        self.extraFeeUseCase = extraFeeUseCase
        self.getVideoListUseCase = getVideoListUseCase
    }
    
    func followingTabText(_ tab: SessionType) -> String {
        switch tab {
        case .privateSession:
            LocalizableText.privateVideoCallLabel
        case .groupSession:
            LocalizableText.groupVideoCallLabel
        case .exclusiveVideo:
            LocalizableText.exclusiveVideoLabel
        }
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
    
    func onGetFollowedCreator() {
        Task {
            await self.getFollowedCreator()
        }
    }
    
    func onGetRateCardList() {
        Task {
            await self.getRateCardList()
        }
    }
    
    func onGetAllSession() {
        Task {
            await self.getAllSession()
        }
    }
    
    func onGetRecentCreatorList() {
        Task {
            await self.getRecentCreatorList()
        }
    }
    
    func onGetPopularCreatorList() {
        Task {
            await self.getPopularCreatorList()
        }
    }
    
    func onSendFreePayment() {
        Task {
            await sendFreePayment()
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
            self.onGetFirstBanner(geo: geo)
            self.onGetSecondBanner(geo: geo)
            self.takeItem = 10
            self.selectedCategoryId = 0
            self.selectedCategory = ""
            self.onGetRateCardList()
            self.onGetAllSession()
            self.onGetRecentCreatorList()
            self.onGetPopularCreatorList()
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
    
    func routeToTalentProfile(showingRequest: Bool = false) {
        let viewModel = TalentProfileDetailViewModel(backToHome: {self.route = nil}, username: self.username.orEmpty(), showingRequest: showingRequest)
        
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
            case .followedCreator:
                self?.isLoadingFollowedCreator = true
            case .none:
                break
            case .followUnfollow(let index):
                self?.isLoadingFollowUnfollow[index] = true
            case .rateCard:
                self?.isLoadingRateCard = true
            case .allSession:
                self?.isLoadingAllSession = true
            case .popularCreator:
                self?.isLoadingPopularCreator = true
            case .recentCreator:
                self?.isLoadingRecentCreator = true
            case .checkPromoCode:
                self?.promoCodeError = false
                self?.promoCodeSuccess = false
                self?.isPromoCodeLoading = true
                self?.promoCodeData = nil
                self?.promoCodeTextArray = []
            case .coinPay:
                self?.isLoadingCoinPay = true
            case .freePayment:
                self?.isLoadingFreePayment = true
            case .verifyCoin:
                self?.isLoadingTrx = true
            case .extraFee:
                self?.isLoadingExtraFee = true
                self?.isFreeBookingSucceed = false
            case .followingSession(let isLoadMore):
                if isLoadMore {
                    self?.isLoadMoreFollowingSession = true
                } else {
                    self?.isLoadingFollowingSession = true
                }
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
    
    @MainActor
    func onFollowUnfollowCreator(id: String?, index: Int) {
        if isFollowed[index] {
            Task {
                await unfollowCreator(id: id, index: index)
            }
        } else {
            Task {
                await followCreator(id: id, index: index)
            }
        }
    }
    
    @MainActor
    func checkPromoCode() async {
        onStartedFetch(type: .checkPromoCode)
        
        let body = PromoCodeRequest(code: promoCode, meetingId: "", paymentMethodId: 10)

        let result = await promoCodeCheckingUseCase.execute(with: body)
        
        switch result {
        case .success(let success):
            self.promoCodeData = success
            
            if success.discountTotal.orZero() != 0 {
                if success.discountTotal.orZero() > (Int(self.sessionCard.price ?? "").orZero() + self.extraFee) {
                    self.totalPayment = 0
                } else {
                    self.totalPayment = Int(self.sessionCard.price ?? "").orZero() + self.extraFee - success.discountTotal.orZero()
                }
            } else if success.amount.orZero() != 0 && success.discountTotal.orZero() == 0 {
                if success.amount.orZero() > (Int(self.sessionCard.price ?? "").orZero() + self.extraFee) {
                    self.totalPayment = 0
                } else {
                    self.totalPayment = Int(self.sessionCard.price ?? "").orZero() + self.extraFee - success.amount.orZero()
                }
            }

            self.promoCodeTextArray = success.defineDiscountString()
            
            self.promoCodeSuccess = true
            self.isPromoCodeLoading = false
        case .failure(let failure):
            handleDefaultError(error: failure, type: .checkPromoCode)
        }
    }
    
    @MainActor
    func coinPayment() async {
        onStartedFetch(type: .coinPay)
        
        let coin = CoinPaymentRequest(
            meetingId: sessionCard.id,
            voucherCode: promoCode.isEmpty ? nil : promoCode,
            meetingBundleId: sessionCard.meetingBundleId.orEmpty()
        )

        let result = await coinPaymentUseCase.execute(with: coin)
        
        switch result {
        case .success(let success):
            self.onGetUser()
            
            self.isShowPaymentOption = false
            self.isShowCoinPayment = false
            self.isShowAddCoin = false
            self.isTransactionSucceed = false
            self.isLoadingCoinPay = false
            
            let viewModel = InvoicesBookingViewModel(bookingId: (success.bookingPayment?.bookingID).orEmpty(), backToHome: {self.route = nil}, backToChoosePayment: {self.route = nil})
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.route = .bookingInvoice(viewModel: viewModel)
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .coinPay)
        }
    }
    
    @MainActor
    func sendFreePayment() async {
        onStartedFetch(type: .freePayment)
        
        let params = BookingPaymentRequest(
            paymentMethod: 99,
            meetingId: sessionCard.id.orEmpty().isEmpty ? nil : sessionCard.id,
            meetingBundleId: sessionCard.meetingBundleId.orEmpty().isEmpty ? nil : sessionCard.meetingBundleId.orEmpty()
        )

        let result = await bookingPaymentUseCase.execute(with: params)
        
        switch result {
        case .success(let success):
            self.isLoadingFreePayment = false
            self.isShowSessionDetail = false
            self.isFreeBookingSucceed = true
            
            let viewModel = InvoicesBookingViewModel(bookingId: (success.bookingPayment?.bookingID).orEmpty(), backToHome: {self.route = nil}, backToChoosePayment: {self.route = nil})
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.route = .bookingInvoice(viewModel: viewModel)
            }
            
        case .failure(let failure):
            handleDefaultError(error: failure, type: .freePayment)
        }
    }
    
    @MainActor
    func verifyCoin(receipt: String) async {
        let result = await coinVerificationUseCase.execute(with: receipt)
        
        switch result {
        case .success:
            self.onGetUser()
            
            self.isLoadingTrx = false
            self.isError = false
            self.error = nil

            self.isShowAddCoin.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                self.isTransactionSucceed.toggle()
            }
            self.productSelected = nil
        case .failure(let failure):
            handleDefaultError(error: failure, type: .verifyCoin)
        }
    }
    
    @MainActor
    func extraFees() async {
        onStartedFetch(type: .extraFee)
        
        let body = PaymentExtraFeeRequest(meetingId: sessionCard.id)
        
        let result = await extraFeeUseCase.execute(by: body)
        
        switch result {
        case .success(let success):
            self.extraFee = success
            self.totalPayment = success + Int(self.sessionCard.price ?? "").orZero()
            
            self.isError = false
            self.isLoadingExtraFee = false
            self.success = true
        case .failure(let failure):
            handleDefaultError(error: failure, type: .extraFee)
        }
    }
    
    @MainActor
    func followCreator(id: String?, index: Int) async {
        onStartedFetch(type: .followUnfollow(index))
        
        let result = await followUseCase.execute(for: id.orEmpty())
        
        switch result {
        case .success:
            self.isFollowed[index] = true
            self.isLoadingFollowUnfollow[index] = false
        case .failure(let error):
            handleDefaultError(error: error, type: .followUnfollow(index))
        }
    }
    
    @MainActor
    func unfollowCreator(id: String?, index: Int) async {
        onStartedFetch(type: .followUnfollow(index))
        
        let result = await unfollowUseCase.execute(for: id.orEmpty())
        
        switch result {
        case .success:
            self.isFollowed[index] = false
            self.isLoadingFollowUnfollow[index] = false
        case .failure(let error):
            handleDefaultError(error: error, type: .followUnfollow(index))
        }
    }
    
    @MainActor
    func getAllSession() async {
        onStartedFetch(type: .allSession)
        
        let param = HomeContentRequest()
        
        let result = await getAllSessionUseCase.execute(with: param)
        
        switch result {
        case .success(let response):
            self.allSessionData = response.data ?? []
            withAnimation {
                self.isLoadingAllSession = false
            }
            
        case .failure(let error):
            handleDefaultError(error: error, type: .allSession)
        }
    }
    
    @MainActor
    func getRecentCreatorList() async {
        onStartedFetch(type: .recentCreator)
        
        let param = HomeContentRequest()
        
        let result = await getRecentCreatorListUseCase.execute(with: param)
        
        switch result {
        case .success(let response):
            self.recentCreatorList = response.data ?? []
            withAnimation {
                self.isLoadingRecentCreator = false
            }
            
        case .failure(let error):
            handleDefaultError(error: error, type: .recentCreator)
        }
    }
    
    @MainActor
    func getPopularCreatorList() async {
        onStartedFetch(type: .popularCreator)
        
        let param = TalentsRequest(skip: 0, take: 10, followed: false)
        
        let result = await getPopularCreatorUseCase.execute(query: param)
        
        switch result {
        case .success(let response):
            self.popularCreatorList = (response.data ?? [])
            self.isFollowed = self.popularCreatorList.compactMap({ _ in
                false
            })
            self.isLoadingFollowUnfollow = self.popularCreatorList.compactMap({ _ in
                false
            })
            withAnimation {
                self.isLoadingPopularCreator = false
            }
            
        case .failure(let error):
            handleDefaultError(error: error, type: .popularCreator)
        }
    }
    
    @MainActor
    func getRateCardList() async {
        onStartedFetch(type: .rateCard)
        
        let param = HomeContentRequest()
        
        let result = await getRateCardListUseCase.execute(with: param)
        
        switch result {
        case .success(let response):
            self.rateCardList = response.data ?? []
            withAnimation {
                self.isLoadingRateCard = false
            }
            
        case .failure(let error):
            handleDefaultError(error: error, type: .rateCard)
        }
    }
    
    @MainActor
    func getFollowedCreator() async {
        onStartedFetch(type: .followedCreator)
        
        let param = GeneralParameterRequest(skip: 0, take: 5)
        
        let result = await followedCreatorUseCase.execute(with: param)
        
        switch result {
        case .success(let response):
            self.success = true
            self.followedCreator = response.data ?? []
            
            withAnimation {
                self.isLoadingFollowedCreator = false
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .followedCreator)
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
                self?.hasNewNotifInbox = success.inboxCount.orZero() > 0
                self?.notificationInboxBadgeCountStr = success.inboxCount.orZero() > 9 ? "9+" : "\(success.inboxCount.orZero())"
                self?.notificationBadgeCountStr = success.unreadNotificationCount.orZero() > 9 ? "9+" : "\(success.unreadNotificationCount.orZero())"
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
        
        let result = await getPrivateUseCase.execute(with: FollowingContentRequest())
        
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
        
        let result = await getGroupUseCase.execute(with: FollowingContentRequest())
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoadingGroupFeature = false
                self?.groupScheduleContent = success.data ?? []
                if (self?.groupScheduleContent ?? []).isEmpty {
                    self?.sessionTab = .privateSession
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .groupFeature)
        }
    }
    
    @MainActor
    func onGetFollowingSession(onRefresh: Bool = false, isMore: Bool) {
        if onRefresh {
            followingPrivate = []
            followingPrivateParam.skip = 0
            followingPrivateParam.take = 10
            
            followingGroup = []
            followingGroupParam.skip = 0
            followingGroupParam.take = 10
            
            followingVideos = []
            followingVideoParam.skip = 0
            followingVideoParam.take = 10
        }
        
        switch followingSessionTab {
        case .privateSession:
            if isMore {
                self.followingPrivateParam.skip = self.followingPrivateParam.take
                self.followingPrivateParam.take += 10
            } else {
                self.followingPrivateParam.skip = 0
                self.followingPrivateParam.take = 10
            }
            
            Task {
                if onRefresh || isMore {
                    await getFollowingPrivate(isMore: isMore)
                } else {
                    if followingPrivate.isEmpty {
                        await getFollowingPrivate(isMore: isMore)
                    }
                }
            }
            
        case .groupSession:
            if isMore {
                self.followingGroupParam.skip = self.followingGroupParam.take
                self.followingGroupParam.take += 10
            } else {
                self.followingGroupParam.skip = 0
                self.followingGroupParam.take = 10
            }
            
            Task {
                if onRefresh || isMore {
                    await getFollowingGroup(isMore: isMore)
                } else {
                    if followingGroup.isEmpty {
                        await getFollowingGroup(isMore: isMore)
                    }
                }
            }
            
        case .exclusiveVideo:
            if isMore {
                self.followingVideoParam.skip = self.followingVideoParam.take
                self.followingVideoParam.take += 10
            } else {
                self.followingVideoParam.skip = 0
                self.followingVideoParam.take = 10
            }
            
            Task {
                if onRefresh || isMore {
                    await getFollowingVideo(isMore: isMore)
                } else {
                    if followingVideos.isEmpty {
                        await getFollowingVideo(isMore: isMore)
                    }
                }
            }
        }
    }
    
    @MainActor
    func getFollowingPrivate(isMore: Bool) async {
        onStartedFetch(type: .followingSession(isMore))
        
        let result = await getPrivateUseCase.execute(with: followingPrivateParam)
        
        switch result {
        case .success(let success):
            if isMore {
                self.followingPrivate += success.data ?? []
                withAnimation {
                    self.isLoadMoreFollowingSession = false
                }
            } else {
                self.followingPrivate = success.data ?? []
                withAnimation {
                    self.isLoadingFollowingSession = false
                }
            }
            self.followingPrivateNextCursor = success.nextCursor
        case .failure(let failure):
            handleDefaultError(error: failure, type: .followingSession(isMore))
        }
    }
    
    @MainActor
    func getFollowingGroup(isMore: Bool) async {
        onStartedFetch(type: .followingSession(isMore))
        
        let result = await getGroupUseCase.execute(with: followingGroupParam)
        
        switch result {
        case .success(let success):
            if isMore {
                self.followingGroup += success.data ?? []
                withAnimation {
                    self.isLoadMoreFollowingSession = false
                }
            } else {
                self.followingGroup = success.data ?? []
                withAnimation {
                    self.isLoadingFollowingSession = false
                }
            }
            self.followingGroupNextCursor = success.nextCursor
        case .failure(let failure):
            handleDefaultError(error: failure, type: .followingSession(isMore))
        }
    }
    
    @MainActor
    func getFollowingVideo(isMore: Bool) async {
        onStartedFetch(type: .followingSession(isMore))
        
        let result = await getVideoListUseCase.execute(with: followingVideoParam)
        
        switch result {
        case .success(let success):
            if isMore {
                self.followingVideos += success.data ?? []
                withAnimation {
                    self.isLoadMoreFollowingSession = false
                }
            } else {
                self.followingVideos = success.data ?? []
                withAnimation {
                    self.isLoadingFollowingSession = false
                }
            }
            self.followingVideoNextCursor = success.nextCursor
        case .failure(let failure):
            handleDefaultError(error: failure, type: .followingSession(isMore))
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
    
    func seeDetailMeeting(from data: MeetingDetailResponse) {
        sessionCard = data
        if data.price == "0" {
            freeTrans = true
        } else {
            freeTrans = false
        }
        isShowSessionDetail = true
    }
    
    func seeDetailMeeting(from data: UserMeetingData) {
        sessionCard = MeetingDetailResponse(id: data.id.orEmpty(), title: data.title, description: data.meetingDescription, price: data.price, startAt: data.startAt, endAt: data.endAt, isPrivate: data.isPrivate, isLiveStreaming: data.isLiveStreaming, participants: data.participants, slots: data.slots, userId: data.userID, startedAt: data.startedAt, endedAt: data.endedAt, createdAt: data.createdAt, updatedAt: data.updatedAt, deletedAt: data.deletedAt, meetingBundleId: data.meetingBundleId, meetingRequestId: data.meetingRequestId, user: data.user, background: data.background, meetingCollaborations: data.meetingCollaborations, meetingUrls: data.meetingUrls, meetingUploads: data.meetingUploads, isCollaborationAlreadyConfirmed: true, meetingRequest: data.meetingRequest, status: data.status, roomSid: data.roomSid, dyteMeetingId: data.dyteMeetingId, isInspected: data.isInspected, reviews: data.reviews, participantDetails: data.participantDetails)
        if data.price == "0" {
            freeTrans = true
        } else {
            freeTrans = false
        }
        isShowSessionDetail = true
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
            case .followedCreator:
                self?.isLoadingFollowedCreator = false
            case .none:
                break
            case .followUnfollow(let index):
                self?.isLoadingFollowUnfollow[index] = false
            case .rateCard:
                self?.isLoadingRateCard = false
            case .allSession:
                self?.isLoadingAllSession = false
            case .popularCreator:
                self?.isLoadingPopularCreator = false
            case .recentCreator:
                self?.isLoadingRecentCreator = false
            case .checkPromoCode:
                self?.isPromoCodeLoading = false
            case .coinPay:
                self?.isLoadingCoinPay = false
            case .freePayment:
                self?.isLoadingFreePayment = false
            case .verifyCoin:
                self?.isLoadingTrx = false
                self?.productSelected = nil
            case .extraFee:
                self?.isLoadingExtraFee = false
            case .followingSession(let isLoadMore):
                self?.isLoadMoreFollowingSession = false
                self?.isLoadingFollowingSession = false
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
            default:
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
    
    func routeToInbox() {
        let viewModel = InboxViewModel()
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .inbox(viewModel: viewModel)
        }
    }

	func routeToNotification() {
		let viewModel = NotificationViewModel(backToHome: { self.route = nil })

		DispatchQueue.main.async { [weak self] in
			self?.route = .notification(viewModel: viewModel)
		}
	}
    
    func routeToFollowedCreator() {
        let viewModel = FollowedCreatorViewModel(backToHome: { self.route = nil })
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .followedCreator(viewModel: viewModel)
        }
    }
    
    func routeToPaymentMethod() {
        let viewModel = PaymentMethodsViewModel(price: sessionCard.price.orEmpty(), meetingId: sessionCard.id.orEmpty(), rateCardMessage: "", requestTime: "", isRateCard: false, backToHome: {self.route = nil})

        DispatchQueue.main.async { [weak self] in
            self?.route = .paymentMethod(viewModel: viewModel)
        }
    }
    
    func routeToDetailVideo(id: String) {
        let viewModel = DetailVideoViewModel(videoId: id, backToHome: { self.route = nil })
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .detailVideo(viewModel: viewModel)
        }
    }
}

extension UserHomeViewModel: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {[weak self] in
            self?.isError = false
            self?.error = nil
        }

        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.myProducts.append(fetchedProduct)
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                DispatchQueue.main.async {[weak self] in
                    self?.isLoadingTrx = true
                    self?.isError = false
                    self?.error = nil
                }
                transactionState = .purchasing
            case .purchased:
                transactionState = .purchased
                queue.finishTransaction(transaction)

                if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                     FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {

                    Task {
                        do {
                            let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                            print(receiptData)

                            let receiptString = receiptData.base64EncodedString(options: [])

                            await self.verifyCoin(receipt: receiptString)
                        }
                        catch {
                            DispatchQueue.main.async {[weak self] in
                                self?.isLoadingTrx = false
                                self?.isError.toggle()
                                self?.error = error.localizedDescription
                            }
                        }
                    }
                }
            case .restored:
                DispatchQueue.main.async {[weak self] in
                    self?.isLoadingTrx = false
                    self?.isError = false
                    self?.error = nil
                }
                transactionState = .restored
                queue.finishTransaction(transaction)
                isShowAddCoin.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self.isTransactionSucceed.toggle()
                }
                productSelected = nil
            case .failed, .deferred:
                transactionState = .failed
                queue.finishTransaction(transaction)
                DispatchQueue.main.async {[weak self] in
                    self?.isLoadingTrx = false
                    self?.isError.toggle()
                    self?.error = LocaleText.inAppsPurchaseTrx
                }
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    func getProducts(productIDs: [String]) {
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func getProductOnAppear() {
        getProducts(productIDs: productIDs)
    }
    
    func resetStateCode() {
        DispatchQueue.main.async { [weak self] in
            self?.promoCode = ""
            self?.promoCodeError = false
            self?.promoCodeSuccess = false
            self?.promoCodeData = nil
            self?.promoCodeTextArray = []
            self?.totalPayment = Int((self?.sessionCard.price).orEmpty()).orZero() + (self?.extraFee).orZero()
        }
    }
    
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().add(self)
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)

        } else {
            DispatchQueue.main.async {[weak self] in
                self?.isError.toggle()
                self?.error = LocalizableText.inAppPurchaseErrorTrx
            }
        }
    }
}
