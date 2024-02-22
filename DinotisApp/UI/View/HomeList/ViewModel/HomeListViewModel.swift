//
//  HomeListViewModel.swift
//  DinotisApp
//
//  Created by Irham Naufal on 07/02/24.
//

import Combine
import DinotisData
import DinotisDesignSystem
import OneSignal
import StoreKit
import SwiftUI

enum HomeListType {
    case session
    case creator
    
    var title: String {
        switch self {
        case .session:
            LocalizableText.allSessionLabel
        case .creator:
            LocalizableText.findCreatorsLabel
        }
    }
}

final class HomeListViewModel: NSObject, ObservableObject {
    
    private let searchCreatorUseCase: SearchCreatorUseCase
    private let getRecentCreatorListUseCase: GetHomeCreatorListUseCase
    private let getPopularCreatorUseCase: GetCrowdedTalentUseCase
    private let searchSessionUseCase: SearchSessionUseCase
    private let getPrivateUseCase: GetPrivateFeatureUseCase
    private let getGroupUseCase: GetGroupFeatureUseCase
    private let followUseCase: FollowCreatorUseCase
    private let unfollowUseCase: UnfollowCreatorUseCase
    private let promoCodeCheckingUseCase: PromoCodeCheckingUseCase
    private let coinPaymentUseCase: CoinPaymentUseCase
    private let bookingPaymentUseCase: BookingPaymentUseCase
    private let coinVerificationUseCase: CoinVerificationUseCase
    private let extraFeeUseCase: GetExtraFeeUseCase
    private let getUserUseCase: GetUserUseCase
    
    private var stateObservable = StateObservable.shared
    
    @Published var type: HomeListType
    
    @Published var userData: UserResponse?
    
    var backToHome: () -> Void
    
    enum TabFilter {
        case all, justJoined, popular
        case nearest, groupCall, privateCall
        
        var title: String {
            switch self {
            case .all:
                LocalizableText.tabAllText
            case .justJoined:
                LocalizableText.justJoinedLabel
            case .popular:
                LocalizableText.popularLabel
            case .nearest:
                LocalizableText.nearestSessionLabel
            case .groupCall:
                LocalizableText.groupVideoCallLabel
            case .privateCall:
                LocalizableText.privateVideoCallLabel
            }
        }
    }
    
    var tabFilters: [TabFilter] {
        switch type {
        case .session:
            return [.nearest, .groupCall, .privateCall]
        case .creator:
            return [.all, .justJoined, .popular]
        }
    }
    
    @Published var currentTab: TabFilter
    
    @Published var searchedCreator = [TalentWithProfessionData]()
    @Published var searchedSession = [MeetingDetailResponse]()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var route: HomeRouting?
    
    @Published var isSearching = false
    @Published var searchText = ""
    @Published var debouncedText = ""
    
    @Published var isFollowed: [Bool] = []
    @Published var isLoadingFollowUnfollow: [Bool] = []
    
    @Published var isShowAlert = false
    @Published var alert = AlertAttribute()
    
    @Published var isLoading = false
    @Published var isLoadMore = false
    @Published var isError = false
    
    @Published var takeItem = 30
    @Published var skip = 0
    @Published var nextCursor: Int? = 0
    
    @Published var isShowSessionDetail = false
    @Published var isShowCollabList = false
    
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
    @Published var isLoadingCoinPay = false
    @Published var isLoadingFreePayment = false
    @Published var isLoadingTrx = false
    @Published var isLoadingExtraFee = false
    
    @Published var isShowPaymentOption = false
    @Published var isShowCoinPayment = false
    @Published var isShowAddCoin = false
    @Published var freeTrans = false
    
    init(
        type: HomeListType,
        tab: TabFilter,
        backToHome: @escaping () -> Void,
        searchCreatorUseCase: SearchCreatorUseCase = SearchCreatorDefaultUseCase(),
        getRecentCreatorListUseCase: GetHomeCreatorListUseCase = GetHomeCreatorListDefaultUseCas(),
        getPopularCreatorUseCase: GetCrowdedTalentUseCase = GetCrowdedTalentDefaultUseCase(),
        searchSessionUseCase: SearchSessionUseCase = SearchSessionDefaultUseCase(),
        getPrivateUseCase: GetPrivateFeatureUseCase = GetPrivateFeatureDefaultUseCase(),
        getGroupUseCase: GetGroupFeatureUseCase = GetGroupFeatureDefaultUseCase(),
        promoCodeCheckingUseCase: PromoCodeCheckingUseCase = PromoCodeCheckingDefaultUseCase(),
        coinPaymentUseCase: CoinPaymentUseCase = CoinPaymentDefaultUseCase(),
        bookingPaymentUseCase: BookingPaymentUseCase = BookingPaymentDefaultUseCase(),
        coinVerificationUseCase: CoinVerificationUseCase = CoinVerificationDefaultUseCase(),
        extraFeeUseCase: GetExtraFeeUseCase = GetExtraFeeDefaultUseCase(),
        followUseCase: FollowCreatorUseCase = FollowCreatorDefaultUseCase(),
        unfollowUseCase: UnfollowCreatorUseCase = UnfollowCreatorDefaultUseCase(),
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase()
    ) {
        self.backToHome = backToHome
        self.type = type
        self.searchCreatorUseCase = searchCreatorUseCase
        self.getRecentCreatorListUseCase = getRecentCreatorListUseCase
        self.getPopularCreatorUseCase = getPopularCreatorUseCase
        self.searchSessionUseCase = searchSessionUseCase
        self.getGroupUseCase = getGroupUseCase
        self.getPrivateUseCase = getPrivateUseCase
        self.currentTab = tab
        self.followUseCase = followUseCase
        self.unfollowUseCase = unfollowUseCase
        self.promoCodeCheckingUseCase = promoCodeCheckingUseCase
        self.coinPaymentUseCase = coinPaymentUseCase
        self.bookingPaymentUseCase = bookingPaymentUseCase
        self.coinVerificationUseCase = coinVerificationUseCase
        self.extraFeeUseCase = extraFeeUseCase
        self.getUserUseCase = getUserUseCase
        super.init()
        self.getSearchedData()
    }
    
    func debounceText() {
        $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                self?.debouncedText = text
            })
            .store(in: &cancellables)
    }
    
    func onStartedFetchSearch(isMore: Bool, isRefresh: Bool) {
        DispatchQueue.main.async {[weak self] in
            withAnimation {
                if !isMore {
                    self?.takeItem = 30
                }
                if isMore {
                    self?.isLoadMore = true
                } else {
                    self?.isLoading = !isRefresh
                }
                self?.isError = false
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
            }
        }
    }
    
    func onStartedFetch(type: AudienceHomeLoadType) {
        DispatchQueue.main.async {[weak self] in
            self?.isError = false
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
            default:
                break
            }
        }
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.isLoadMore = false
            
            if let error = error as? ErrorResponse {
                if error.statusCode.orZero() == 401 {
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
                    self?.isError = true
                    self?.alert.isError = true
                    self?.alert.message = error.message.orEmpty()
                    self?.isShowAlert = true
                }
            } else {
                self?.isError = true
                self?.alert.isError = true
                self?.alert.message = error.localizedDescription
                self?.isShowAlert = true
            }
            
        }
    }
    
    func handleDefaultError(error: Error, type: AudienceHomeLoadType) {
        DispatchQueue.main.async { [weak self] in
            switch type {
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
            default:
                break
            }
            
            if let error = error as? ErrorResponse {
                
                if error.statusCode.orZero() == 401 {
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
                    self?.isError = true
                    self?.alert.isError = true
                    self?.alert.message = error.message.orEmpty()
                    self?.isShowAlert = true
                }
            } else {
                self?.isError = true
                self?.alert.isError = true
                self?.alert.message = error.localizedDescription
                self?.isShowAlert = true
            }
            
        }
    }
    
    func onGetUser() {
        Task {
            await self.getUsers()
        }
    }
    
    func onSendFreePayment() {
        Task {
            await sendFreePayment()
        }
    }
    
    func getSearchedData(isMore: Bool = false, isRefresh: Bool = false) {
        Task {
            switch currentTab {
            case .all:
                await getSearchedCreator(isMore: isMore, isRefresh: isRefresh)
            case .justJoined:
                await getJustJoinedCreator(isMore: isMore, isRefresh: isRefresh)
            case .popular:
                await getPopularCreator(isMore: isMore, isRefresh: isRefresh)
            case .nearest:
                await getSearchedSession(isMore: isMore, isRefresh: isRefresh)
            case .groupCall:
                await getGroupSessions(isMore: isMore, isRefresh: isRefresh)
            case .privateCall:
                await getPrivateSessions(isMore: isMore, isRefresh: isRefresh)
            }
        }
    }
    
    private func getSearchedSession(isMore: Bool, isRefresh: Bool) async {
        onStartedFetchSearch(isMore: isMore, isRefresh: isRefresh)
        
        let query = SearchQueryParam(
            query: searchText,
            skip: takeItem-30,
            take: takeItem,
            sort: .newest
        )
        
        let result = await searchSessionUseCase.execute(query: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    if isMore {
                        self?.searchedSession += success.data ?? []
                    } else {
                        self?.searchedSession = success.data ?? []
                    }
                    
                    self?.isError = false
                    self?.isLoading = false
                    self?.isLoadMore = false
                    self?.nextCursor = success.nextCursor
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    private func getGroupSessions(isMore: Bool, isRefresh: Bool) async {
        onStartedFetchSearch(isMore: isMore, isRefresh: isRefresh)
        
        let query = FollowingContentRequest(
            query: searchText,
            skip: takeItem-30,
            take: takeItem
        )
        
        let result = await getGroupUseCase.execute(with: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    if isMore {
                        self?.searchedSession += (success.data ?? []).compactMap({ self?.convertMeetingData(from: $0) })
                    } else {
                        self?.searchedSession = (success.data ?? []).compactMap({ self?.convertMeetingData(from: $0) })
                    }
                    
                    self?.isError = false
                    self?.isLoading = false
                    self?.isLoadMore = false
                    self?.nextCursor = success.nextCursor
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    private func getPrivateSessions(isMore: Bool, isRefresh: Bool) async {
        onStartedFetchSearch(isMore: isMore, isRefresh: isRefresh)
        
        let query = FollowingContentRequest(
            query: searchText,
            skip: takeItem-30,
            take: takeItem
        )
        
        let result = await getPrivateUseCase.execute(with: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    if isMore {
                        self?.searchedSession += (success.data ?? []).compactMap({ self?.convertMeetingData(from: $0) })
                    } else {
                        self?.searchedSession = (success.data ?? []).compactMap({ self?.convertMeetingData(from: $0) })
                    }
                    
                    self?.isError = false
                    self?.isLoading = false
                    self?.isLoadMore = false
                    self?.nextCursor = success.nextCursor
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    private func convertMeetingData(from data: UserMeetingData) -> MeetingDetailResponse {
        MeetingDetailResponse(
            id: data.id.orEmpty(),
            title: data.title,
            description: data.meetingDescription,
            price: data.price,
            startAt: data.startAt,
            endAt: data.endAt,
            isPrivate: data.isPrivate,
            isLiveStreaming: data.isLiveStreaming,
            participants: data.participants,
            slots: data.slots, userId: data.userID,
            startedAt: data.startedAt,
            endedAt: data.endedAt,
            createdAt: data.createdAt,
            updatedAt: data.updatedAt,
            deletedAt: data.deletedAt,
            meetingBundleId: data.meetingBundleId,
            meetingRequestId: data.meetingRequestId,
            user: data.user, 
            background: data.background,
            meetingCollaborations: data.meetingCollaborations,
            meetingUrls: data.meetingUrls,
            meetingUploads: data.meetingUploads,
            isCollaborationAlreadyConfirmed: true,
            bookings: data.bookings?.compactMap({convertBookData(from: $0)}),
            meetingRequest: data.meetingRequest,
            status: data.status,
            roomSid: data.roomSid,
            dyteMeetingId: data.dyteMeetingId,
            isInspected: data.isInspected,
            reviews: data.reviews,
            participantDetails: data.participantDetails
        )
    }
    
    private func convertBookData(from data: BookedData) -> UserBookingData {
        UserBookingData(
            id: data.id,
            bookedAt: data.bookedAt,
            canceledAt: data.canceledAt,
            doneAt: data.doneAt,
            meetingID: data.meetingID,
            userID: data.userID,
            createdAt: data.createdAt,
            updatedAt: data.updatedAt,
            bookingPayment: data.bookingPayment
        )
    }
    
    private func getSearchedCreator(isMore: Bool, isRefresh: Bool) async {
        onStartedFetchSearch(isMore: isMore, isRefresh: isRefresh)
        
        let query = SearchQueryParam(
            query: searchText,
            skip: takeItem-30,
            take: takeItem
        )
        
        let result = await searchCreatorUseCase.execute(query: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    if isMore {
                        self?.isFollowed += (success.data ?? []).compactMap({ $0.isFollowed })
                        self?.isLoadingFollowUnfollow = self?.isFollowed.compactMap({ _ in
                            false
                        }) ?? []
                        self?.searchedCreator += success.data ?? []
                    } else {
                        self?.isFollowed = (success.data ?? []).compactMap({ $0.isFollowed })
                        self?.isLoadingFollowUnfollow = self?.isFollowed.compactMap({ _ in
                            false
                        }) ?? []
                        self?.searchedCreator = success.data ?? []
                    }
                    
                    self?.isError = false
                    self?.isLoading = false
                    self?.isLoadMore = false
                    self?.nextCursor = success.nextCursor
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    private func getPopularCreator(isMore: Bool, isRefresh: Bool) async {
        onStartedFetchSearch(isMore: isMore, isRefresh: isRefresh)
        
        let query = TalentsRequest(
            query: searchText,
            skip: takeItem-30,
            take: takeItem
        )
        
        let result = await getPopularCreatorUseCase.execute(query: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    if isMore {
                        self?.isFollowed += (success.data ?? []).compactMap({ $0.isFollowed })
                        self?.isLoadingFollowUnfollow = self?.isFollowed.compactMap({ _ in
                            false
                        }) ?? []
                        self?.searchedCreator += success.data ?? []
                    } else {
                        self?.isFollowed = (success.data ?? []).compactMap({ $0.isFollowed })
                        self?.isLoadingFollowUnfollow = self?.isFollowed.compactMap({ _ in
                            false
                        }) ?? []
                        self?.searchedCreator = success.data ?? []
                    }
                    
                    self?.isError = false
                    self?.isLoading = false
                    self?.isLoadMore = false
                    self?.nextCursor = success.nextCursor
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    private func getJustJoinedCreator(isMore: Bool, isRefresh: Bool) async {
        onStartedFetchSearch(isMore: isMore, isRefresh: isRefresh)
        
        let query = HomeContentRequest(
            query: searchText,
            skip: takeItem-30,
            take: takeItem,
            sort: .newest
        )
        
        let result = await getRecentCreatorListUseCase.execute(with: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    if isMore {
                        self?.isFollowed += (success.data ?? []).compactMap({ $0.isFollowed })
                        self?.isLoadingFollowUnfollow = self?.isFollowed.compactMap({ _ in
                            false
                        }) ?? []
                        self?.searchedCreator += success.data ?? []
                    } else {
                        self?.isFollowed = (success.data ?? []).compactMap({ $0.isFollowed })
                        self?.isLoadingFollowUnfollow = self?.isFollowed.compactMap({ _ in
                            false
                        }) ?? []
                        self?.searchedCreator = success.data ?? []
                    }
                    
                    self?.isError = false
                    self?.isLoading = false
                    self?.isLoadMore = false
                    self?.nextCursor = success.nextCursor
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
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
    func unfollowCreator(id: String?, index: Int) async {
        isLoadingFollowUnfollow[index] = true
        
        let result = await unfollowUseCase.execute(for: id.orEmpty())
        
        switch result {
        case .success:
            self.isFollowed[index] = false
            self.isLoadingFollowUnfollow[index] = false
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    @MainActor
    func followCreator(id: String?, index: Int) async {
        isLoadingFollowUnfollow[index] = true
        
        let result = await followUseCase.execute(for: id.orEmpty())
        
        switch result {
        case .success:
            self.isFollowed[index] = true
            self.isLoadingFollowUnfollow[index] = false
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
    
    func getUsers() async {
        onStartedFetch(type: .none)
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.userData = success
                self?.stateObservable.userId = success.id.orEmpty()
                OneSignal.setExternalUserId(success.id.orEmpty())
                OneSignal.sendTag("isTalent", value: "false")
            }
        case .failure(let failure):
            handleDefaultError(error: failure, type: .none)
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
            
        case .failure(let failure):
            handleDefaultError(error: failure, type: .extraFee)
        }
    }
    
    func routeToCreatorProfile(username: String) {
        let viewModel = TalentProfileDetailViewModel(backToHome: backToHome, username: username)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .talentProfileDetail(viewModel: viewModel)
        }
    }
    
    func routeToPaymentMethod() {
        let viewModel = PaymentMethodsViewModel(price: sessionCard.price.orEmpty(), meetingId: sessionCard.id.orEmpty(), rateCardMessage: "", requestTime: "", isRateCard: false, backToHome: backToHome)

        DispatchQueue.main.async { [weak self] in
            self?.route = .paymentMethod(viewModel: viewModel)
        }
    }
    
    func openWhatsApp() {
        if let waurl = URL(string: "https://wa.me/6281318506068") {
            if UIApplication.shared.canOpenURL(waurl) {
                UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
            }
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
}

extension HomeListViewModel: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {[weak self] in
            self?.isError = false
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
                            }
                        }
                    }
                }
            case .restored:
                DispatchQueue.main.async {[weak self] in
                    self?.isLoadingTrx = false
                    self?.isError = false
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
            }
        }
    }
}
