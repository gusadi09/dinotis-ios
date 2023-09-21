//
//  RateCardServiceBookingFormViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/10/22.
//

import Combine
import DinotisData
import DinotisDesignSystem
import StoreKit
import SwiftUI
import OneSignal

enum RateCardBookingSheetState: Identifiable {
    var id: UUID {
        UUID()
    }
    
    case detailOrder
    case cancelled
}

final class RateCardServiceBookingFormViewModel: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    private let extraFeeUseCase: GetExtraFeeUseCase
    private let rateCardPaymentUseCase: RateCardPaymentUseCase
    private let coinVerificationUseCase: CoinVerificationUseCase
    private let getUserUseCase: GetUserUseCase
    private let promoCodeCheckingUseCase: PromoCodeCheckingUseCase
    
    private var cancellables = Set<AnyCancellable>()
    private var stateObservable = StateObservable.shared
    
    var backToHome: () -> Void
    
    @Published var route: HomeRouting?
    
    @Published var isShowDatePicker = false
    @Published var isShowTimePicker = false
    
    @Published var dateSuggestion = Date()
    @Published var changedDateSuggestion = Date()
    
    @Published var isLoading = false
    @Published var isLoadingCoinPay = false
    @Published var isError = false
    @Published var success = false
    @Published var error: String?
    
    @Published var isRefreshFailed = false
    
    @Published var isShowAlert = false
    @Published var alert = AlertAttribute()
    
    @Published var isTextComplete = false
    @Published var isDescComplete = false
    
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
    @Published var isLoadingTrx = false
    @Published var promoCodeTextArray = [String]()
    
    @Published var isShowCoinPayment = false
    
    @Published var totalPayment = 0
    @Published var extraFee = 0
    @Published var isPresent = false
    
    @Published var userData: UserResponse?
    @Published var rateCard: RateCardResponse
    
    @Published var promoCodeSuccess = false
    @Published var promoCodeError = false
    @Published var promoCodeData: PromoCodeResponse?
    @Published var isPromoCodeLoading = false
    @Published var promoCode = ""
    
    @Published var noteText = ""
    
    @Published var talentName: String
    @Published var talentPhoto: String
    
    init(
        backToHome: @escaping (() -> Void),
        rateCardPaymentUseCase: RateCardPaymentUseCase = RateCardPaymentDefaultUseCase(),
        extraFeeUseCase: GetExtraFeeUseCase = GetExtraFeeDefaultUseCase(),
        coinVerificationUseCase: CoinVerificationUseCase = CoinVerificationDefaultUseCase(),
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        promoCodeCheckingUseCase: PromoCodeCheckingUseCase = PromoCodeCheckingDefaultUseCase(),
        talentName: String = "",
        talentPhoto: String = "",
        rateCard: RateCardResponse = RateCardResponse(id: "", title: "", description: "", price: "", duration: 0, isPrivate: nil)
    ) {
        self.backToHome = backToHome
        self.rateCardPaymentUseCase = rateCardPaymentUseCase
        self.extraFeeUseCase = extraFeeUseCase
        self.coinVerificationUseCase = coinVerificationUseCase
        self.getUserUseCase = getUserUseCase
        self.promoCodeCheckingUseCase = promoCodeCheckingUseCase
        self.talentName = talentName
        self.talentPhoto = talentPhoto
        self.rateCard = rateCard
    }
    
    @objc func onScreenAppear() {
        Task {
            await getUsers()
        }
    }
    
    func onStartFetch() {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
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
    
    func getUsers() async {
        onStartFetch()
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                self?.userData = success
                self?.stateObservable.userId = success.id.orEmpty()
            }
        case .failure(let failure):
            handleDefaultErrorFreePayment(error: failure)
        }
    }
    
    func resetStateCode() {
        DispatchQueue.main.async { [weak self] in
            self?.promoCode = ""
            self?.promoCodeError = false
            self?.promoCodeSuccess = false
            self?.promoCodeData = nil
            self?.promoCodeTextArray = []
            self?.totalPayment = Int((self?.rateCard.price).orEmpty()).orZero() + (self?.extraFee).orZero()
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
    
    func handleDefaultErrorFreePayment(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()
                
                
                if error.statusCode.orZero() == 401 {
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
                            OneSignal.setExternalUserId("")
                        }
                    )
                    self?.isShowAlert = true
                } else {
                    self?.isError = true
                    self?.alert.title = LocalizableText.alertFailedRequestSessionTitle
                    self?.alert.message = LocalizableText.alertFailedRequestSessionMessage
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
    
    func extraFees() async {
        onStartFetch()
        
        let body = PaymentExtraFeeRequest(rateCardId: rateCard.id.orEmpty())
        
        let result = await extraFeeUseCase.execute(by: body)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.success = true
                self?.isLoading = false
                
                self?.extraFee = success
                
                self?.totalPayment = success + Int((self?.rateCard.price).orEmpty()).orZero()
            }
        case .failure(let failure):
            handleDefaultErrorFreePayment(error: failure)
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
            self?.isLoadingTrx = false
            self?.productSelected = nil
            
            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()
                
                
                if error.statusCode.orZero() == 401 {
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
                            OneSignal.setExternalUserId("")
                        }
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
                self?.error = error.localizedDescription
                self?.alert.isError = true
                self?.alert.message = error.localizedDescription
                self?.isShowAlert = true
            }
            
        }
    }
    
    func verifyCoin(receipt: String) async {
        onStartFetch()
        
        let result = await coinVerificationUseCase.execute(with: receipt)
        
        switch result {
        case .success(_):
            await self.getUsers()
            DispatchQueue.main.async {[weak self] in
                self?.isLoadingTrx = false
                self?.isLoading = false
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
    
    func handleDefaultErrorCoinPayment(error: Error, action: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoadingCoinPay = false
            
            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()
                
                
                if error.statusCode.orZero() == 401 {
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
                            OneSignal.setExternalUserId("")
                        }
                    )
                    self?.isShowAlert = true
                } else {
                    self?.isError = true
                    self?.alert.title = LocalizableText.alertFailedRequestSessionTitle
                    self?.alert.message = LocalizableText.alertFailedRequestSessionMessage
                    self?.alert.isError = true
                    self?.alert.primaryButton = .init(
                        text: LocalizableText.resendLabel,
                        action: { action() }
                    )
                    self?.alert.secondaryButton = .init(
                        text: LocalizableText.cancelLabel,
                        action: {}
                    )
                    self?.isShowAlert = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }
            
        }
    }
    
    func coinPayment() async {
        onStartPay()
        
        let body = RequestSessionRequest(rateCardId: rateCard.id.orEmpty(), message: noteText, requestAt: dateSuggestion.iso8601withFractionalSeconds)

        let result = await rateCardPaymentUseCase.execute(with: body)

        switch result {
        case .success(let success):

            DispatchQueue.main.async { [weak self] in
                self?.showPaymentMenu = false
                self?.isShowCoinPayment = false
                self?.showAddCoin = false
                self?.isTransactionSucceed = false
                self?.isLoadingCoinPay = false
                
                print("SUCCESSX: ", success)

                let viewModel = InvoicesBookingViewModel(bookingId: (success.id).orEmpty(), backToHome: self?.backToHome ?? {}, backToChoosePayment: {self?.route = nil})

                self?.alert.title = LocalizableText.alertSuccessRequestSessionTitle
                self?.alert.message = LocalizableText.alertSuccessRequestSessionMessage
                self?.alert.isError = false
                self?.alert.primaryButton = .init(
                    text: LocalizableText.okText,
                    action: {
                        self?.route = .bookingInvoice(viewModel: viewModel)
                    }
                )
                self?.alert.secondaryButton = nil
                self?.isShowAlert = true
            }
        case .failure(let failure):
            DispatchQueue.main.async { [weak self] in
                self?.showPaymentMenu = false
                self?.isShowCoinPayment = false
                self?.showAddCoin = false
                self?.isTransactionSucceed = false
                self?.isLoadingCoinPay = false
            }
            handleDefaultErrorCoinPayment(error: failure) {
                Task {
                    await self.coinPayment()
                }
            }
        }
    }
    
    func onStartCheckCode() {
        DispatchQueue.main.async { [weak self] in
            self?.promoCodeError = false
            self?.promoCodeSuccess = false
            self?.isPromoCodeLoading = true
            self?.promoCodeData = nil
            self?.promoCodeTextArray = []
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
    
    func handleDefaultErrorPromoCodeChecking(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
            
            if let error = error as? ErrorResponse {
                self?.error = error.message.orEmpty()
                
                if error.statusCode.orZero() == 401 {
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
                            OneSignal.setExternalUserId("")
                        }
                    )
                    self?.isShowAlert = true
                } else {
                    self?.promoCodeError = true
                    self?.alert.isError = true
                    self?.alert.message = error.message.orEmpty()
                    self?.isShowAlert = true
                }
            } else {
                self?.promoCodeError = true
                self?.error = error.localizedDescription
                self?.alert.isError = true
                self?.alert.message = error.localizedDescription
                self?.isShowAlert = true
            }
            
        }
    }
    
    func checkPromoCode() async {
        onStartCheckCode()
        
        let body = PromoCodeRequest(code: promoCode, meetingId: "", paymentMethodId: 10)
        
        let result = await promoCodeCheckingUseCase.execute(with: body)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.promoCodeSuccess = true
                self?.isLoading = false
                
                self?.promoCodeData = success
                
                if success.discountTotal.orZero() != 0 {
                    if success.discountTotal.orZero() > (Int((self?.rateCard.price).orEmpty()).orZero() + (self?.extraFee).orZero()) {
                        self?.totalPayment = 0
                    } else {
                        self?.totalPayment = Int((self?.rateCard.price).orEmpty()).orZero() + (self?.extraFee).orZero() - success.discountTotal.orZero()
                    }
                } else if success.amount.orZero() != 0 && success.discountTotal.orZero() == 0 {
                    if success.amount.orZero() > (Int((self?.rateCard.price).orEmpty()).orZero() + (self?.extraFee).orZero()) {
                        self?.totalPayment = 0
                    } else {
                        self?.totalPayment = Int((self?.rateCard.price).orEmpty()).orZero() + (self?.extraFee).orZero() - success.amount.orZero()
                    }
                }
                
                self?.promoCodeTextArray = success.defineDiscountString()
            }
        case .failure(let failure):
            handleDefaultErrorPromoCodeChecking(error: failure)
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
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                DispatchQueue.main.async {[weak self] in
                    withAnimation {
                        self?.isLoadingTrx = true
                        self?.isError = false
                        self?.error = nil
                    }
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
                        } catch {
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
                    withAnimation {
                        self?.isLoadingTrx = false
                        self?.isError = false
                        self?.error = nil
                    }
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
                        self?.isLoadingTrx = false
                        self?.isError.toggle()
                        self?.error = LocaleText.inAppsPurchaseTrx
                    }
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
    
    func routeToPaymentMethod(price: String, rateCardId: String) {
        let viewModel = PaymentMethodsViewModel(price: price, meetingId: rateCardId, rateCardMessage: noteText, requestTime: dateSuggestion.toStringFormat(with: .utc), isRateCard: true, backToHome: self.backToHome)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .paymentMethod(viewModel: viewModel)
        }
    }
}
