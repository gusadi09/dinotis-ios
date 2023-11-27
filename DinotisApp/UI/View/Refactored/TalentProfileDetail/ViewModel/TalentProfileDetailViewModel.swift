//
//  TalentProfileDetailViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/03/22.
//

import Foundation
import Combine
import SwiftUI
import UIKit
import StoreKit
import OneSignal
import DinotisData
import DinotisDesignSystem

enum LoadMoreType {
    case rateCard
    case review
    case meeting
    case video
}

enum StudioVideosFilter {
    case latest
    case recorded
    case publicAudience
    case earliest
    case archive
}

final class TalentProfileDetailViewModel: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var backToHome: () -> Void
    
    private var stateObservable = StateObservable.shared
    private let getTalentDetailUseCase: GetDetailTalentUseCase
    private let sendScheduleRequestUseCase: SendRequestedScheduleUseCase
    private let getUserUseCase: GetUserUseCase
    private var cancellables = Set<AnyCancellable>()
    private let bookingPaymentUseCase: BookingPaymentUseCase
    private let coinPaymentUseCase: CoinPaymentUseCase
    private let coinVerificationUseCase: CoinVerificationUseCase
    private let promoCodeCheckingUseCase: PromoCodeCheckingUseCase
    private let rateCardRepository: RateCardRepository
    private let friendshipRepository: FriendshipRepository
    private let extraFeeUseCase: GetExtraFeeUseCase
    private let getRateCardUseCase: GetAudienceRateCardUseCase
    private let followUseCase: FollowCreatorUseCase
    private let unfollowUseCase: UnfollowCreatorUseCase
    private let getReviewsUseCase: GetReviewsUseCase
    private let getTalentDetailMeetingUseCase: GetCreatorDetailMeetingListUseCase
    private let getVideoListUseCase: GetVideoListUseCase
    private let subscribeUseCase: SubscribeUseCase
    
    @Published var filterSelection = LocalizableText.talentDetailAvailableSessions
    @Published var filterSelectionReview = "Semua Ulasan"
    
    @Published var isDescComplete = false
    
    @Published var route: HomeRouting?
    @Published var tabNumb = 0
    
    @Published var showingRequest = false
    
    @Published var showMenuCard = false
    
    @Published var selectedMeeting: MeetingDetailResponse?
    
    @Published var nextCursorRateCard: Int? = 0
    @Published var nextCursorMeeting: Int? = 0
    @Published var nextCursorReview: Int? = 0
    
    @Published var isLoadingFollow = false
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var isLoadingMoreRateCard = false
    @Published var isLoadingMoreReview = false
    @Published var isLoadingVideoList = false
    @Published var isLoadingMoreVideoList = false
    @Published var isError = false
    @Published var success = false
    @Published var error: String?
    
    @Published var alert = AlertAttribute()
    @Published var isShowAlert = false
    
    @Published var currentImageIndex = 0
    @Published var isShowImageDetail = false
    
    @Published var isShowManagements = false
    @Published var isShowCollabList = false
    
    @Published var methodName = ""
    @Published var methodIcon = ""
    
    @Published var isRefreshFailed = false
    @Published var freeTrans = false
    
    @Published var redirectUrl: String?
    @Published var qrCodeUrl: String?
    
    @Published var config = Configuration.shared
    
    @Published var urlLinked = Configuration.shared.environment.openURL
    
    @Published var userData: UserResponse?
    @Published var userName: String?
    @Published var userPhoto: String?
    
    @Published var talentData: TalentFromSearchResponse?
    @Published var talentName: String?
    @Published var talentPhoto: String?
    
    @Published var profileBanner = [HighlightData]()
    @Published var profileBannerContent = [ProfileBannerImageTemp]()
    
    @Published var countPart = 0
    @Published var totalPart = 0
    @Published var title = ""
    @Published var desc = ""
    @Published var date = ""
    @Published var timeStart = ""
    @Published var timeEnd = ""
    @Published var price = ""
    @Published var meetingId = ""
    @Published var bundlingId = ""
    @Published var isBundling = false
    @Published var session = 0
    @Published var textJob = ""
    
    @Published var totalPayment = 0
    @Published var extraFee = 0
    
    @Published var isLoadingPaySubs = false
    @Published var isSuccessSubs = false
    
    @Published var isPresent = false
    @Published var bookingId = ""
    @Published var filterOption = [OptionQueryResponse]()
    @Published var filterOptionReview = [OptionQuery]()
    @Published var meetingData = [MeetingDetailResponse]()
    @Published var bundlingData = [DinotisData.BundlingData]()
    @Published var rateCardList = [RateCardResponse]()
    @Published var reviewData = [ReviewData]()
    @Published var videos = [MineVideoData]()
    
    var videoParam: VideoListRequest {
        var param: VideoListRequest = .init(username: (self.talentData?.username).orEmpty())
        let unsubscribed = talentData?.subscription == nil || talentData?.subscription?.subscriptionType == "UNSUBSCRIBED"
        
        param.audienceType = unsubscribed ? .PUBLIC : .SUBSCRIBER
        
        switch currentSection {
        case .recorded:
            param.videoType = .RECORD
        case .publicAudience:
            param.audienceType = .PUBLIC
        case .earliest:
            param.sort = .asc
        default:
            param.sort = .desc
        }
        
        return param
    }
    
    @Published var payments = UserBookingPayment(
        id: "",
        amount: "",
        bookingID: "",
        paymentMethodID: 0,
        externalId: nil,
        redirectUrl: nil,
        qrCodeUrl: nil
    )
    
    @Published var query = RateCardFilterRequest()
    
    @Published var meetingParam = MeetingsPageRequest(take: 15, skip: 0, isStarted: "", isEnded: "false", isAvailable: "true")
    @Published var reviewParam = GeneralParameterRequest(skip: 0, take: 15)
    
    @Published var isLiveStream = false
    
    @Published var username: String
    
    @Published var isShare = false
    
    @Published var requestSuccess = false
    @Published var requestError = false
    
    private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
    
    @Published var showPaymentMenu = false
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
    
    @Published var transactionState: SKPaymentTransactionState?
    @Published var showAddCoin = false
    @Published var productSelected: SKProduct? = nil
    @Published var isTransactionSucceed = false
    @Published var isLoadingTrxs = false
    
    @Published var isShowCoinPayment = false
    
    @Published var promoCodeSuccess = false
    @Published var promoCodeError = false
    @Published var promoCodeData: PromoCodeResponse?
    @Published var isPromoCodeLoading = false
    
    @Published var promoCode = ""
    @Published var invoiceNumber = ""
    
    @Published var isLoadingCoinPay = false
    
    @Published var promoCodeTextArray = [String]()
    
    @Published var imageIndex = 0
    
    @Published var currentSection: StudioVideosFilter = .latest
    @Published var sections: [StudioVideosFilter] = [.latest, .recorded, .earliest, .publicAudience]
    
    @Published var isLockPrivate = false
    @Published var requestSessionMessage = ""
    @Published var requestSessionType: RequestScheduleType = .groupType
    var requestSessionText: String {
        switch requestSessionType {
        case .privateType:
            LocalizableText.privateVideoCallLabel
        default:
            LocalizableText.groupVideoCallLabel
        }
    }
    
    @Published var isShowBundlingSheet = false
    
    @Published var isShowSubscribeSheet = false
    @Published var isLastSubscribeSheet = false
    var subsSheetHeight: CGFloat {
        isLastSubscribeSheet ? 450 : 320
    }
    
    var professionText: String {
        var profession = ""
        
        let data = talentData?.professions?.compactMap({
            $0.profession?.name
        })
        
        profession = (data?.joined(separator: ", ")).orEmpty()
        
        return profession
    }
    
    var isManagementView: Bool {
        talentData?.management != nil
    }
    
    init(
        backToHome: @escaping (() -> Void),
        username: String,
        getTalentDetailUseCase: GetDetailTalentUseCase = GetDetailTalentDefaultUseCase(),
        sendScheduleRequestUseCase: SendRequestedScheduleUseCase = SendRequestedScheduleDefaultUseCase(),
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        bookingPaymentUseCase: BookingPaymentUseCase = BookingPaymentDefaultUseCase(),
        promoCodeCheckingUseCase: PromoCodeCheckingUseCase = PromoCodeCheckingDefaultUseCase(),
        coinPaymentUseCase: CoinPaymentUseCase = CoinPaymentDefaultUseCase(),
        rateCardRepository: RateCardRepository = RateCardDefaultRepository(),
        getReviewsUseCase: GetReviewsUseCase = GetReviewsDefaultUseCase(),
        friendshipRepository: FriendshipRepository = FriendshipDefaultRepository(),
        extraFeeUseCase: GetExtraFeeUseCase = GetExtraFeeDefaultUseCase(),
        getRateCardUseCase: GetAudienceRateCardUseCase = GetAudienceRateCardDefaultUseCase(),
        followUseCase: FollowCreatorUseCase = FollowCreatorDefaultUseCase(),
        unfollowUseCase: UnfollowCreatorUseCase = UnfollowCreatorDefaultUseCase(),
        coinVerificationUseCase: CoinVerificationUseCase = CoinVerificationDefaultUseCase(),
        getTalentDetailMeetingUseCase: GetCreatorDetailMeetingListUseCase = GetCreatorDetailMeetingListDefaultUseCase(),
        getVideoListUseCase: GetVideoListUseCase = GetVideoListDefaultUseCase(),
        subscribeUseCase: SubscribeUseCase = SubscribeDefaultUseCase()
    ) {
        self.username = username
        self.backToHome = backToHome
        self.getTalentDetailUseCase = getTalentDetailUseCase
        self.sendScheduleRequestUseCase = sendScheduleRequestUseCase
        self.getUserUseCase = getUserUseCase
        self.bookingPaymentUseCase = bookingPaymentUseCase
        self.promoCodeCheckingUseCase = promoCodeCheckingUseCase
        self.coinPaymentUseCase = coinPaymentUseCase
        self.rateCardRepository = rateCardRepository
        self.getReviewsUseCase = getReviewsUseCase
        self.friendshipRepository = friendshipRepository
        self.extraFeeUseCase = extraFeeUseCase
        self.getRateCardUseCase = getRateCardUseCase
        self.followUseCase = followUseCase
        self.unfollowUseCase = unfollowUseCase
        self.coinVerificationUseCase = coinVerificationUseCase
        self.getTalentDetailMeetingUseCase = getTalentDetailMeetingUseCase
        self.getVideoListUseCase = getVideoListUseCase
        self.subscribeUseCase = subscribeUseCase
    }
    
    func subscribeURL() -> String {
        return urlLinked + "user/talent/" + (talentData?.username).orEmpty()
    }
    
    func chipText(_ section: StudioVideosFilter) -> String {
        switch section {
        case .earliest:
            LocalizableText.sortEarliest
        case .latest:
            LocalizableText.sortLatest
        case .recorded:
            LocalizableText.recordedLabel
        case .publicAudience:
            LocalizableText.publicLabel
        case .archive:
            LocalizableText.archiveLabel
        }
    }
    
    func dateFormatter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy"
        return formatter.string(from: date)
    }
    
    func routeToInvoice(id: String) {
        let viewModel = DetailPaymentViewModel(
            backToHome: self.backToHome,
            backToChoosePayment: {},
            bookingId: id,
            subtotal: "",
            extraFee: "",
            serviceFee: ""
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .detailPayment(viewModel: viewModel)
        }
    }
    
    func onStartPay() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoadingCoinPay = true
            self?.isError = false
            self?.error = nil
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
    
    func onGetExtraFee() {
        Task {
            await extraFees()
        }
    }
    
    func onSendFreePayment(completion: @escaping () -> Void) {
        Task {
            await sendFreePayment(completion: completion)
        }
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.showingRequest = false
            self?.showPaymentMenu = false
            self?.isShowCoinPayment = false
            self?.showAddCoin = false
            self?.isLoadingPaySubs = false
            self?.alert.title = LocalizableText.attentionText
            
            if let error = error as? ErrorResponse {
                
                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                    self?.alert.isError = true
                    self?.alert.message = LocalizableText.alertSessionExpired
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            self?.routeToRoot()
                        }
                    )
                    self?.isShowAlert = true
                } else {
                    self?.error = error.message.orEmpty()
                    self?.isError = true
                    self?.alert.message = error.message.orEmpty()
                    self?.alert.isError = true
                    self?.isShowAlert = true
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            
                        }
                    )
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
    
    func sendFreePayment(completion: @escaping () -> Void) async {
        onStartedFetch(noLoad: false)
        let params = BookingPaymentRequest(paymentMethod: 99, meetingId: self.meetingId.isEmpty ? nil : self.meetingId, meetingBundleId: bundlingId.isEmpty ? nil : bundlingId)
        
        let result = await bookingPaymentUseCase.execute(with: params)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.freeTrans = true
                self?.isLoading = false
                self?.alert.title = LocalizableText.alertSuccessBookingTitle
                self?.alert.message = LocalizableText.alertSuccessBookingMessage
                self?.alert.primaryButton = .init(
                    text: LocalizableText.okText,
                    action: {
                        self?.backToHome()
                        completion()
                    }
                )
                self?.isShowAlert = true
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
        
    }
    
    func coinPayment() async {
        onStartPay()
        
        let coin = CoinPaymentRequest(meetingId: meetingId.isEmpty ? nil : meetingId, voucherCode: promoCode.isEmpty ? nil : promoCode, meetingBundleId: bundlingId.isEmpty ? nil : bundlingId)
        
        let result = await coinPaymentUseCase.execute(with: coin)
        
        switch result {
        case .success(let success):
            await self.getUsers()
            DispatchQueue.main.async { [weak self] in
                self?.showPaymentMenu = false
                self?.isShowCoinPayment = false
                self?.showAddCoin = false
                self?.isTransactionSucceed = false
                self?.isLoadingCoinPay = false
                
                let viewModel = InvoicesBookingViewModel(bookingId: (success.bookingPayment?.bookingID).orEmpty(), backToHome: self?.backToHome ?? {}, backToChoosePayment: {self?.route = nil})
                self?.alert.title = LocalizableText.alertSuccessBookingTitle
                self?.alert.message = LocalizableText.alertSuccessBookingMessage
                self?.alert.primaryButton = .init(
                    text: LocalizableText.okText,
                    action: {
                        self?.route = .bookingInvoice(viewModel: viewModel)
                    }
                )
                self?.isShowAlert = true
            }
            
            self.onScreenAppear()
        case .failure(let failure):
            handleDefaultErrorCoinPayment(error: failure)
        }
    }
    
    func handleDefaultErrorCoinPayment(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoadingCoinPay = false
            self?.showPaymentMenu = false
            self?.isShowCoinPayment = false
            self?.showAddCoin = false
            
            self?.alert.title = LocalizableText.attentionText
            
            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()
                
                
                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                    self?.alert.isError = true
                    self?.alert.message = LocalizableText.alertSessionExpired
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            self?.routeToRoot()
                        }
                    )
                    self?.isShowAlert = true
                } else {
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
    
    func resetStateCode() {
        DispatchQueue.main.async { [weak self] in
            self?.promoCode = ""
            self?.promoCodeError = false
            self?.promoCodeSuccess = false
            self?.promoCodeData = nil
            self?.promoCodeTextArray = []
            self?.totalPayment = Int((self?.selectedMeeting?.price).orEmpty()).orZero() + (self?.extraFee).orZero()
        }
    }
    
    func onStartCheckCode() {
        DispatchQueue.main.async { [weak self] in
            self?.promoCodeError = false
            self?.promoCodeSuccess = false
            self?.isPromoCodeLoading = true
            self?.promoCodeData = nil
            self?.promoCodeTextArray = []
        }
    }
    
    func handleDefaultErrorPromoCodeChecking(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            self?.alert.title = LocalizableText.attentionText
            
            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()
                
                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                    self?.alert.isError = true
                    self?.alert.message = LocalizableText.alertSessionExpired
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            self?.routeToRoot()
                        }
                    )
                    self?.isShowAlert = true
                } else {
                    self?.promoCodeError = true
                }
            } else {
                self?.promoCodeError = true
                self?.error = error.localizedDescription
            }
            
        }
    }
    
    func checkPromoCode() async {
        onStartCheckCode()
        
        let body = PromoCodeRequest(code: promoCode, meetingId: meetingId, paymentMethodId: 10)
        
        let result = await promoCodeCheckingUseCase.execute(with: body)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.promoCodeSuccess = true
                self?.isLoading = false
                self?.promoCodeData = success
                
                if success.discountTotal.orZero() != 0 {
                    if success.discountTotal.orZero() > (Int(self?.selectedMeeting?.price ?? "").orZero() + (self?.extraFee).orZero()) {
                        self?.totalPayment = 0
                    } else {
                        self?.totalPayment = Int(self?.selectedMeeting?.price ?? "").orZero() + (self?.extraFee).orZero() - success.discountTotal.orZero()
                    }
                } else if success.amount.orZero() != 0 && success.discountTotal.orZero() == 0 {
                    if success.amount.orZero() > (Int(self?.selectedMeeting?.price ?? "").orZero() + (self?.extraFee).orZero()) {
                        self?.totalPayment = 0
                    } else {
                        self?.totalPayment = Int(self?.selectedMeeting?.price ?? "").orZero() + (self?.extraFee).orZero() - success.amount.orZero()
                    }
                }
                
                self?.promoCodeTextArray = success.defineDiscountString()
            }
        case .failure(let failure):
            handleDefaultErrorPromoCodeChecking(error: failure)
        }
    }
    
    func extraFees() async {
        onStartedFetch(noLoad: false)
        
        let body = PaymentExtraFeeRequest(meetingId: meetingId.isEmpty ? nil : meetingId, meetingBundleId: bundlingId.isEmpty ? nil : bundlingId)
        
        print("Extra Fee: ", body)
        
        let result = await extraFeeUseCase.execute(by: body)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                
                self?.extraFee = success
                
                self?.totalPayment = success + Int(self?.selectedMeeting?.price ?? "").orZero()
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func openWhatsApp() {
        if let waurl = URL(string: "https://wa.me/6281318506068") {
            if UIApplication.shared.canOpenURL(waurl) {
                UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
            }
        }
    }
    
    func handleDefaultErrorCoinVerify(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoadingTrxs = false
            self?.productSelected = nil
            
            self?.alert.title = LocalizableText.attentionText
            
            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()
                
                
                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                    self?.alert.isError = true
                    self?.alert.message = LocalizableText.alertSessionExpired
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            self?.routeToRoot()
                        }
                    )
                    self?.isShowAlert = true
                } else {
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
    
    func verifyCoin(receipt: String) async {
        
        let result = await coinVerificationUseCase.execute(with: receipt)
        
        switch result {
        case .success(_):
            await self.getUsers()
            
            DispatchQueue.main.async {[weak self] in
                self?.isLoadingTrxs = false
                self?.isError = false
                self?.error = nil
                
                
                self?.showAddCoin.toggle()
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self?.isTransactionSucceed.toggle()
                }
                
                self?.productSelected = nil
            }
        case .failure(let failure):
            handleDefaultErrorCoinVerify(error: failure)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                DispatchQueue.main.async {[weak self] in
                    self?.isLoadingTrxs = true
                    self?.isError = false
                    self?.error = nil
                }
                transactionState = .purchasing
            case .purchased:
                print("purchased")
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
                                self?.isLoadingTrxs = false
                                self?.isError.toggle()
                                self?.error = error.localizedDescription
                            }
                        }
                    }
                }
            case .restored:
                DispatchQueue.main.async {[weak self] in
                    self?.isLoadingTrxs = false
                    self?.isError = false
                    self?.error = nil
                }
                transactionState = .restored
                queue.finishTransaction(transaction)
                showAddCoin.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self.isTransactionSucceed.toggle()
                }
                productSelected = nil
            case .failed, .deferred:
                transactionState = .failed
                queue.finishTransaction(transaction)
                DispatchQueue.main.async {[weak self] in
                    withAnimation {
                        self?.isLoadingTrxs = false
                        self?.isError.toggle()
                        self?.error = LocaleText.inAppsPurchaseTrx
                    }
                }
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().add(self)
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
            
        } else {
            DispatchQueue.main.async {[weak self] in
                withAnimation {
                    self?.isError.toggle()
                    self?.error = LocaleText.inAppsPurchaseTrx
                }
            }
            
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {[weak self] in
            withAnimation {
                self?.isError.toggle()
                self?.error = error.localizedDescription
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {[weak self] in
            withAnimation {
                self?.isError = false
                self?.error = nil
            }
        }
        
        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.myProducts.append(fetchedProduct)
                }
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
    
    @objc func onScreenAppear() {
        Task {
            await getTalentFromSearch(by: username)
            await getUsers()
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
    
    func onDisappearView() {
        self.talentName = ""
        self.talentPhoto = ""
        self.isPresent = false
        SKPaymentQueue.default().remove(self)
    }
    
    func startSendRequest() {
        DispatchQueue.main.async {[weak self] in
            self?.requestError = false
            self?.isLoading = true
            self?.error = nil
            self?.requestSuccess = false
            self?.showingRequest.toggle()
        }
    }
    
    func sendRequest(type: RequestScheduleType, message: String) async {
        startSendRequest()
        
        let body = SendScheduleRequest(requestUserId: (userData?.id).orEmpty(), type: type.rawValue, message: message)
        
        let result = await sendScheduleRequestUseCase.execute(with: (talentData?.id).orEmpty(), for: body)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.requestSuccess = true
                self?.isLoading = false
                self?.showingRequest = false
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func onStartFetch() {
        DispatchQueue.main.async {[weak self] in
            self?.isLoading = true
            self?.isError = false
            self?.error = nil
            self?.isRefreshFailed = false
        }
    }
    
    func onStartFetchFollow() {
        DispatchQueue.main.async {[weak self] in
            self?.isLoadingFollow = true
            self?.isError = false
            self?.error = nil
            self?.isRefreshFailed = false
        }
    }
    
    func followUnfollowCreator() {
        Task {
            if (self.talentData?.isFollowed).orFalse() {
                await unfollowCreator()
            } else {
                await followCreator()
            }
        }
    }
    
    func handleDefaultErrorFollow(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoadingFollow = false
            self?.alert.title = LocalizableText.attentionText
            
            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()
                
                
                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                    self?.alert.isError = true
                    self?.alert.message = LocalizableText.alertSessionExpired
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            self?.routeToRoot()
                        }
                    )
                    self?.isShowAlert = true
                } else {
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
    
    func onGetDetailCreator() {
        Task {
            await self.getTalentFromSearch(by: self.username, noLoad: true)
        }
    }
    
    func followCreator() async {
        onStartFetchFollow()
        
        let result = await followUseCase.execute(for: (talentData?.id).orEmpty())
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoadingFollow = false
                self?.onGetDetailCreator()
            }
        case .failure(let failure):
            handleDefaultErrorFollow(error: failure)
        }
    }
    
    func unfollowCreator() async {
        onStartFetchFollow()
        
        let result = await unfollowUseCase.execute(for: (talentData?.id).orEmpty())
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoadingFollow = false
                self?.onGetDetailCreator()
            }
        case .failure(let failure):
            handleDefaultErrorFollow(error: failure)
        }
    }
    
    func onStartFetchWithPagination(isMore: Bool, type: LoadMoreType) {
        DispatchQueue.main.async { [weak self] in
            if isMore {
                switch type {
                case .meeting:
                    self?.isLoadingMore = true
                case .rateCard:
                    self?.isLoadingMoreRateCard = true
                case .review:
                    self?.isLoadingMoreReview = true
                case .video:
                    self?.isLoadingMoreVideoList = true
                }
                
            } else {
                switch type {
                case .video:
                    self?.isLoadingVideoList = true
                default:
                    self?.isLoading = true
                }
            }
            self?.isError = false
            self?.error = nil
            self?.isRefreshFailed = false
        }
        
    }
    
    func getReviewsList(with creatorId: String, isMore: Bool) async {
        onStartFetchWithPagination(isMore: isMore, type: .review)
        
        let result = await getReviewsUseCase.execute(by: creatorId, for: reviewParam)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async {[weak self] in
                if isMore {
                    self?.isLoadingMoreReview = false
                } else {
                    self?.isLoading = false
                }
                
                withAnimation {
                    self?.reviewData += success.data ?? []
                    self?.nextCursorReview = success.nextCursor
                }
            }
        case .failure(let failure):
            DispatchQueue.main.async {[weak self] in
                if isMore {
                    self?.isLoadingMoreReview = false
                } else {
                    self?.isLoading = false
                }
                self?.alert.title = LocalizableText.attentionText
                
                if let error = failure as? ErrorResponse {
                    
                    if error.statusCode.orZero() == 401 {
                        self?.error = error.message.orEmpty()
                        self?.isRefreshFailed.toggle()
                        self?.alert.isError = true
                        self?.alert.message = LocalizableText.alertSessionExpired
                        self?.alert.primaryButton = .init(
                            text: LocalizableText.okText,
                            action: {
                                self?.routeToRoot()
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
                    self?.error = failure.localizedDescription
                    self?.alert.message = failure.localizedDescription
                    self?.alert.isError = true
                    self?.isShowAlert = true
                }
            }
        }
    }
    
    func getVideoList(isMore: Bool) async {
        onStartFetchWithPagination(isMore: isMore, type: .video)
        
        let result = await getVideoListUseCase.execute(with: videoParam)
        
        switch result {
        case .success(let response):
            DispatchQueue.main.async {[weak self] in
                if isMore {
                    self?.isLoadingMoreVideoList = false
                    self?.videos += response.data ?? []
                } else {
                    self?.isLoadingVideoList = false
                    self?.videos = response.data ?? []
                }
            }
        case .failure(let error):
            print("ERROR ASU: \(error)")
        }
    }
    
    func handleDefaultErrorRateCard(error: Error, isMore: Bool) {
        DispatchQueue.main.async { [weak self] in
            if isMore {
                self?.isLoadingMoreRateCard = false
            } else {
                self?.isLoading = false
            }
            self?.alert.title = LocalizableText.attentionText
            
            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()
                
                
                if error.statusCode.orZero() == 401 {
                    self?.isRefreshFailed.toggle()
                    self?.alert.isError = true
                    self?.alert.message = LocalizableText.alertSessionExpired
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.okText,
                        action: {
                            self?.routeToRoot()
                        }
                    )
                    self?.isShowAlert = true
                } else {
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
    
    func getRateCardList(by creatorId: String, isMore: Bool) async {
        onStartFetchWithPagination(isMore: isMore, type: .rateCard)
        
        let result = await getRateCardUseCase.execute(for: creatorId, with: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                if isMore {
                    self?.isLoadingMoreRateCard = false
                } else {
                    self?.isLoading = false
                }
                
                withAnimation {
                    self?.rateCardList += success.data ?? []
                    self?.nextCursorRateCard = success.nextCursor
                }
            }
        case .failure(let failure):
            handleDefaultErrorRateCard(error: failure, isMore: isMore)
        }
    }
    
    func onStartedFetch(noLoad: Bool) {
        DispatchQueue.main.async {[weak self] in
            self?.isError = false
            
            if !noLoad {
                self?.isLoading = true
            }
            
            self?.error = nil
            self?.success = false
            self?.freeTrans = false
        }
    }
    
    func onStartRefresh() {
        DispatchQueue.main.async { [weak self] in
            self?.isRefreshFailed = false
            self?.isLoading = true
            self?.success = false
            self?.error = nil
            self?.isError = false
        }
    }
    
    func getUsers() async {
        onStartedFetch(noLoad: false)
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.userData = success
                self?.stateObservable.userId = success.id.orEmpty()
                self?.userPhoto = success.profilePhoto
                self?.userName = success.name
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func onGetReviewList(with talentId: String, isMore: Bool) {
        Task {
            await self.getReviewsList(with: talentId, isMore: isMore)
        }
    }
    
    func getTalentFromSearch(by username: String, noLoad: Bool = false) async {
        onStartedFetch(noLoad: noLoad)
        
        let result = await getTalentDetailUseCase.execute(query: username)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                
                self?.talentData = success
                self?.talentPhoto = success.profilePhoto
                self?.talentName = success.name
                
                if !noLoad {
                    self?.onGetTalentMeeting(by: success.id.orEmpty(), isMore: false)
                    self?.onGetRateCardList(by: success.id.orEmpty(), isMore: false)
                    self?.onGetReviewList(with: success.id.orEmpty(), isMore: false)
                }
                
                let stringArrJob = success.professions?.compactMap {
                    $0.profession?.name ?? ""
                }
                
                self?.textJob = (stringArrJob ?? []).joined(separator: ", ")
                
                self?.profileBanner = success.userHighlights ?? []
                
                if !(success.userHighlights ?? []).isEmpty {
                    self?.profileBannerContent = success.userHighlights?.compactMap({
                        ProfileBannerImageTemp(
                            content: $0
                        )
                    }) ?? []
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func getTalentMeeting(by userId: String, isMore: Bool) async {
        onStartFetchWithPagination(isMore: isMore, type: .meeting)
        
        let result = await getTalentDetailMeetingUseCase.execute(for: userId, with: meetingParam)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async {[weak self] in
                self?.success = true
                if isMore {
                    self?.isLoadingMore = false
                } else {
                    self?.isLoading = false
                }
                
                self?.filterOption = success.filters?.options ?? []
                self?.meetingData += success.data?.meetings ?? []
                self?.bundlingData += success.data?.bundles ?? []
                
                self?.nextCursorMeeting = success.nextCursor
            }
            
        case .failure(let failure):
            DispatchQueue.main.async {[weak self] in
                if isMore {
                    self?.isLoadingMore = false
                } else {
                    self?.isLoading = false
                }
                self?.alert.title = LocalizableText.attentionText
                
                if let error = failure as? ErrorResponse {
                    
                    if error.statusCode.orZero() == 401 {
                        self?.error = error.message.orEmpty()
                        self?.isRefreshFailed.toggle()
                        self?.alert.isError = true
                        self?.alert.message = LocalizableText.alertSessionExpired
                        self?.alert.primaryButton = .init(
                            text: LocalizableText.okText,
                            action: {
                                self?.routeToRoot()
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
                    self?.error = failure.localizedDescription
                    self?.alert.message = failure.localizedDescription
                    self?.alert.isError = true
                    self?.isShowAlert = true
                }
            }
        }
    }
    
    func viewExclusiveVideo(id: String) {
        let unsubscribed = talentData?.subscription == nil || talentData?.subscription?.subscriptionType == "UNSUBSCRIBED"
        if unsubscribed {
            alert.title = LocalizableText.subscribeAlertTitle
            alert.message = LocalizableText.subscribeAlertDesc
            alert.primaryButton = .init(text: LocalizableText.okText, action: {})
            DispatchQueue.main.async { [weak self] in
                self?.isShowAlert = true
            }
        } else {
            routeToDetailVideo(id: id)
        }
    }
    
    //  func convertToCardModel(with data: TalentFromSearch) -> CreatorCardModel {
    //    return CreatorCardModel(
    //      name: data.name.orEmpty(),
    //      isVerified: data.isVerified ?? false,
    //      professions: convertToStringProfession(data.stringProfessions),
    //      photo: data.profilePhoto.orEmpty()
    //    )
    //  }
    
    func routeToPaymentMethod(price: String, meetingId: String) {
        let viewModel = PaymentMethodsViewModel(price: price, meetingId: meetingId, rateCardMessage: "", requestTime: "", isRateCard: false, backToHome: self.backToHome)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .paymentMethod(viewModel: viewModel)
        }
    }
    
    func routeToScheduleList() {
        let viewModel = ScheduleListViewModel(backToHome: {self.route = nil}, currentUserId: (userData?.id).orEmpty())
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .scheduleList(viewModel: viewModel)
        }
    }
    
    func routeToUserScheduleDetail() {
        let viewModel = ScheduleDetailViewModel(isActiveBooking: true, bookingId: bookingId, backToHome: self.backToHome, isDirectToHome: false)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .userScheduleDetail(viewModel: viewModel)
        }
    }
    
    func routeToBundlingDetail(bundleId: String, meetingArray: [MeetingDetailResponse], isActive: Bool) {
        let viewModel = BundlingDetailViewModel(bundleId: bundleId, profileDetailBundle: meetingArray, meetingIdArray: [], backToHome: self.backToHome, isTalent: false, isActive: isActive)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .bundlingDetail(viewModel: viewModel)
        }
    }
    
    func routeToRateCardForm(rateCardId: String, title: String, description: String, price: String, duration: Int, isPrivate: Bool) {
        let viewModel = RateCardServiceBookingFormViewModel(backToHome: self.backToHome, talentName: self.talentName.orEmpty(), talentPhoto: self.talentPhoto.orEmpty(), rateCard: RateCardResponse(id: rateCardId, title: title, description: description, price: price, duration: duration, isPrivate: isPrivate))
        
        DispatchQueue.main.async { [weak self] in
            self?.isShowBundlingSheet = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [weak self] in
            self?.route = .rateCardServiceBookingForm(viewModel: viewModel)
        }
    }
    
    func routeToManagement(username: String) {
        let viewModel = TalentProfileDetailViewModel(backToHome: self.backToHome, username: username)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .talentProfileDetail(viewModel: viewModel)
        }
    }
    
    func routeToMyTalent(talent: String) {
        let viewModel = TalentProfileDetailViewModel(backToHome: self.backToHome, username: talent)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .talentProfileDetail(viewModel: viewModel)
        }
    }
    
    func routeToDetailVideo(id: String) {
        let viewModel = DetailVideoViewModel(videoId: id, backToHome: { self.backToHome() })
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .detailVideo(viewModel: viewModel)
        }
    }
    
    func isMeetingId(currentUser: String, bookings: [Booking]) -> String {
        
        for item in bookings where item.userID == currentUser {
            return (item.bookingPayment?.bookingID).orEmpty()
        }
        
        return ""
    }
    
    func use(for scrollView: UIScrollView, onValueChanged: @escaping ((UIRefreshControl) -> Void)) {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: #selector(self.onValueChangedAction),
            for: .valueChanged
        )
        scrollView.refreshControl = refreshControl
        self.onValueChanged = onValueChanged
    }
    
    @objc private func onValueChangedAction(sender: UIRefreshControl) {
        self.resetList()
        onScreenAppear()
        self.onValueChanged?(sender)
    }
    
    func onGetTalentMeeting(by talentId: String, isMore: Bool) {
        Task {
            await self.getTalentMeeting(by: talentId, isMore: isMore)
        }
    }
    
    func onGetRateCardList(by talentId: String, isMore: Bool) {
        Task {
            await self.getRateCardList(by: talentId, isMore: isMore)
        }
    }
    
    func resetList() {
        DispatchQueue.main.async { [weak self] in
            self?.nextCursorMeeting = 0
            self?.nextCursorRateCard = 0
            self?.meetingParam.skip = 0
            self?.meetingParam.take = 15
            self?.meetingData = []
            self?.bundlingData = []
            self?.videos = []
            
            self?.onGetTalentMeeting(by: (self?.talentData?.id).orEmpty(), isMore: false)
            self?.onGetRateCardList(by: (self?.talentData?.id).orEmpty(), isMore: false)
        }
    }
    
    @MainActor func shareSheet(url: String) {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        guard let url = URL(string: url) else { return }
        let activityView = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            DispatchQueue.main.async {
                rootVC.present(activityView, animated: true) {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
            
        }
        
    }
    
    @MainActor
    func subscribe(with methodID: Int) async {
        
        self.isLoadingPaySubs = true
        self.isError = false
        self.error = nil
        self.isRefreshFailed = false
        self.isSuccessSubs = false
        
        let result = await subscribeUseCase.execute(for: (talentData?.id).orEmpty(), with: methodID)
        
        switch result {
        case .success(_):
            self.isSuccessSubs = true
            self.isLoadingPaySubs = false
            
            self.onGetDetailCreator()
        case .failure(let error):
            handleDefaultError(error: error)
        }
    }
}
