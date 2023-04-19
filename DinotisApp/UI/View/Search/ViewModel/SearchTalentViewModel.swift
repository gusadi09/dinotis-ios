//
//  SearchTalentViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/03/22.
//

import Combine
import DinotisData
import DinotisDesignSystem
import Foundation
import UIKit
import StoreKit
import SwiftUI

enum TabFilter {
    case all
    case session
    case creator
}

final class SearchTalentViewModel: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	
	private let authRepository: AuthenticationRepository
    private let getUserUseCase: GetUserUseCase
    private let promoCodeCheckingUseCase: PromoCodeCheckingUseCase
	private let coinPaymentUseCase: CoinPaymentUseCase
	private let bookingPaymentUseCase: BookingPaymentUseCase
    private let rateCardRepository: RateCardRepository
    private let coinVerificationUseCase: CoinVerificationUseCase
    
    private let recommendUseCase: RecommendUseCase
    private let searchCreatorUseCase: SearchCreatorUseCase
    private let searchSessionUseCase: SearchSessionUseCase
    private let extraFeeUseCase: GetExtraFeeUseCase
	
	private var cancellables = Set<AnyCancellable>()
	
	@Published var route: HomeRouting?
	
	@Published var searchText = ""
    @Published var debouncedText = ""
	
	@Published var isLoading = false
    @Published var isLoadingRecommend = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?
  
  @Published var isShowAlert = false
  @Published var alert = AlertAttribute()
	
	@Published var isRefreshFailed = false
	
	@Published var professionId = 0
	@Published var takeItem = 30
    @Published var sessionTakeItem = 30
	@Published var skip = 0
	@Published var sessionNextCursor: Int? = 0
	@Published var creatorNextCursor: Int? = 0
	
	@Published var isSearchLoading = false
    @Published var isLoadingCoinPay = false
    @Published var isLoadingTrx = false
    
    @Published var isTransactionSucceed = false
    @Published var isFreeBookingSucceed = false
    
    @Published var searchedCreator = [TalentWithProfessionData]()
    @Published var searchedSession = [MeetingDetailResponse]()
    @Published var recommendedData = [ReccomendData]()
    
    @Published var isShowSessionDetail = false
    @Published var isDescComplete = false
    
    @Published var sessionCard = MeetingDetailResponse(user: nil, background: [""], meetingCollaborations: nil, meetingUrls: nil, meetingUploads: nil)
    
    @Published var extraFee = 0
    @Published var totalPayment = 0
    
    @Published var userData: UserResponse?
    
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
    
    let tabFilter: [TabFilter] = [.all, .session, .creator]
    @Published var currentTab: TabFilter = .all
    
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
	
	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
        promoCodeCheckingUseCase: PromoCodeCheckingUseCase = PromoCodeCheckingDefaultUseCase(),
		coinPaymentUseCase: CoinPaymentUseCase = CoinPaymentDefaultUseCase(),
        rateCardRepository: RateCardRepository = RateCardDefaultRepository(),
        coinRepository: CoinRepository = CoinDefaultRepository(),
		bookingPaymentUseCase: BookingPaymentUseCase = BookingPaymentDefaultUseCase(),
        recommendUseCase: RecommendUseCase = RecommendDefaultUseCase(),
        searchCreatorUseCase: SearchCreatorUseCase = SearchCreatorDefaultUseCase(),
        searchSessionUseCase: SearchSessionUseCase = SearchSessionDefaultUseCase(),
        extraFeeUseCase: GetExtraFeeUseCase = GetExtraFeeDefaultUseCase(),
		coinVerificationUseCase: CoinVerificationUseCase = CoinVerificationDefaultUseCase()
	) {
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.authRepository = authRepository
        self.getUserUseCase = getUserUseCase
        self.promoCodeCheckingUseCase = promoCodeCheckingUseCase
        self.rateCardRepository = rateCardRepository
        self.coinVerificationUseCase = coinVerificationUseCase
        self.recommendUseCase = recommendUseCase
        self.searchCreatorUseCase = searchCreatorUseCase
        self.searchSessionUseCase = searchSessionUseCase
        self.extraFeeUseCase = extraFeeUseCase
		self.coinPaymentUseCase = coinPaymentUseCase
		self.bookingPaymentUseCase = bookingPaymentUseCase
	}
	
    func routeToTalentProfile(username: String?) {
		let viewModel = TalentProfileDetailViewModel(backToRoot: self.backToRoot, backToHome: {self.route = nil}, username: username.orEmpty())
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .talentProfileDetail(viewModel: viewModel)
		}
	}
    
    func routeToPaymentMethod() {
		let viewModel = PaymentMethodsViewModel(price: sessionCard.price.orEmpty(), meetingId: sessionCard.id.orEmpty(), rateCardMessage: "", isRateCard: false, backToRoot: self.backToRoot, backToHome: {self.route = nil})

        DispatchQueue.main.async { [weak self] in
            self?.route = .paymentMethod(viewModel: viewModel)
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
	
    func onStartedFetch(isRecommend: Bool) {
		DispatchQueue.main.async {[weak self] in
            withAnimation {
                self?.isError = false
                
                if isRecommend {
                    self?.isLoadingRecommend = true
                } else {
                    self?.isLoading = true
                }
                
                self?.error = nil
                self?.success = false
                self?.isFreeBookingSucceed = false
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
  
  func onStartedFetchSearch(isMore: Bool) {
    DispatchQueue.main.async {[weak self] in
      withAnimation {
        self?.isError = false
        self?.isSearchLoading = true
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
        
        if !isMore {
          self?.sessionTakeItem = 30
        }
      }
    }
  }
    
    func tabText(filter: TabFilter) -> String {
        switch filter {
        case .all:
            return LocalizableText.tabAllText
        case .creator:
            return LocalizableText.tabCreator
        case .session:
            return LocalizableText.tabSession
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
    
    func indicatorPosition(filter: TabFilter, width: Double) -> CGFloat {
        switch filter {
        case .all:
            return 0 - width/3
        case .session:
            return (width/3) - width/3
        case .creator:
            return (width * 2/3) - width/3
        }
    }
    
    func openWhatsApp() {
        if let waurl = URL(string: "https://wa.me/6281318506068") {
            if UIApplication.shared.canOpenURL(waurl) {
                UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
            }
        }
    }
    
    func onAppear() {
        Task {
            await getUsers()
            await getRecommendation()
        }
    }
    
	func getSearchedSession(isMore: Bool) async {
		onStartedFetchSearch(isMore: isMore)
        
        let query = SearchQueryParam(
            query: searchText,
            skip: sessionTakeItem-30,
            take: sessionTakeItem,
            profession: professionId,
            professionCategory: 0
        )
        
        let result = await searchSessionUseCase.execute(query: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                withAnimation {
					if isMore {
						self?.searchedSession += success.data ?? []
						self?.searchedSession = self?.searchedSession.unique() ?? []
					} else {
						self?.searchedSession = success.data ?? []
					}
                    
                    self?.isError = false
                    self?.isLoading = false
                    self?.isSearchLoading = false
                    self?.error = nil
                    self?.success = true
					self?.sessionNextCursor = success.nextCursor
                }
            }
        case .failure(let failure):
			handleDefaultError(error: failure)
        }
    }
    
    func getSearchedData(isMore: Bool) async {
        onStartedFetchSearch(isMore: isMore)
        
        let query = SearchQueryParam(
            query: searchText,
            skip: takeItem-30,
            take: takeItem,
            profession: professionId,
            professionCategory: 0
        )
        
        let result = await searchCreatorUseCase.execute(query: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                withAnimation {
					if isMore {
						self?.searchedCreator += success.data ?? []
						self?.searchedCreator = self?.searchedCreator.unique() ?? []
					} else {
						self?.searchedCreator = success.data ?? []
					}
                    
                    self?.isError = false
                    self?.isLoading = false
                    self?.isSearchLoading = false
                    self?.error = nil
                    self?.success = true
					self?.creatorNextCursor = success.nextCursor
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func getRecommendation() async {
        onStartedFetch(isRecommend: true)
        
        let query = SearchQueryParam(
            query: "",
            skip: 0,
            take: 10,
            profession: 0,
            professionCategory: 0
        )
        
        let result = await recommendUseCase.execute(query: query)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                withAnimation {
                    self?.recommendedData = success
                    
                    self?.isError = false
                    self?.isLoadingRecommend = false
                    self?.error = nil
                    self?.success = true
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func extraFees() async {
        onStartedFetch(isRecommend: false)
        
        let body = PaymentExtraFeeRequest(meetingId: sessionCard.id)
        
        let result = await extraFeeUseCase.execute(by: body)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.extraFee = success
                self?.totalPayment = success + Int(self?.sessionCard.price ?? "").orZero()
                
                self?.isError = false
                self?.isLoading = false
                self?.success = true
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
    }
    
    func getUsers() async {
        onStartedFetch(isRecommend: false)
        
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
            handleDefaultError(error: failure)
        }
    }
	
	func onStartRefresh() {
    DispatchQueue.main.async { [weak self] in
      self?.isRefreshFailed = false
      self?.isLoading = true
      self?.success = false
      self?.error = nil
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
            primaryButton: .init(
              text: LocalizableText.closeLabel,
              action: {}
            ),
            secondaryButton: nil
          )
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
					if success.discountTotal.orZero() > (Int(self?.sessionCard.price ?? "").orZero() + (self?.extraFee).orZero()) {
						self?.totalPayment = 0
					} else {
						self?.totalPayment = Int(self?.sessionCard.price ?? "").orZero() + (self?.extraFee).orZero() - success.discountTotal.orZero()
					}
				} else if success.amount.orZero() != 0 && success.discountTotal.orZero() == 0 {
					if success.amount.orZero() > (Int(self?.sessionCard.price ?? "").orZero() + (self?.extraFee).orZero()) {
						self?.totalPayment = 0
					} else {
						self?.totalPayment = Int(self?.sessionCard.price ?? "").orZero() + (self?.extraFee).orZero() - success.amount.orZero()
					}
				}

				self?.promoCodeTextArray = success.defineDiscountString()
			}
		case .failure(let failure):
			handleDefaultErrorPromoCodeChecking(error: failure)
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
            action: { self?.backToRoot() }
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

	func handleDefaultError(error: Error) {
		DispatchQueue.main.async { [weak self] in
            self?.isLoadingRecommend = false
			self?.isLoading = false
			self?.isSearchLoading = false
			self?.success = false

			if let error = error as? ErrorResponse {
				self?.error = error.message.orEmpty()

				if error.statusCode.orZero() == 401 {
					self?.isRefreshFailed.toggle()
          self?.alert.isError = true
          self?.alert.message = LocalizableText.alertSessionExpired
          self?.alert.primaryButton = .init(
            text: LocalizableText.okText,
            action: { self?.backToRoot() }
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

	func handleDefaultErrorCoinPayment(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoadingCoinPay = false
			self?.isShowPaymentOption = false
			self?.isShowCoinPayment = false
			self?.isShowAddCoin = false

			if let error = error as? ErrorResponse {
				self?.error = error.message.orEmpty()

				if error.statusCode.orZero() == 401 {
					self?.isRefreshFailed.toggle()
          self?.alert.isError = true
          self?.alert.message = LocalizableText.alertSessionExpired
          self?.alert.primaryButton = .init(
            text: LocalizableText.okText,
            action: { self?.backToRoot() }
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
            primaryButton: .init(
              text: LocalizableText.closeLabel,
              action: {}
            ),
            secondaryButton: nil
          )
        }
    }
    
    func coinPayment() async {
        onStartPay()
        
        let coin = CoinPaymentRequest(
            meetingId: sessionCard.id,
            voucherCode: promoCode.isEmpty ? nil : promoCode,
            meetingBundleId: sessionCard.meetingBundleId.orEmpty()
        )

		let result = await coinPaymentUseCase.execute(with: coin)

		switch result {
		case .success(let success):
            await self.getUsers()
			DispatchQueue.main.async { [weak self] in
				self?.isShowPaymentOption = false
				self?.isShowCoinPayment = false
				self?.isShowAddCoin = false
				self?.isTransactionSucceed = false
				self?.isLoadingCoinPay = false

				let viewModel = InvoicesBookingViewModel(bookingId: (success.bookingPayment?.bookingID).orEmpty(), backToRoot: self?.backToRoot ?? {}, backToHome: {self?.route = nil}, backToChoosePayment: {self?.route = nil})
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
          self?.route = .bookingInvoice(viewModel: viewModel)
        }
			}
		case .failure(let failure):
			handleDefaultErrorCoinPayment(error: failure)
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
            action: { self?.backToRoot() }
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

		let result = await coinVerificationUseCase.execute(with: receipt)

		switch result {
		case .success(_):
            await self.getUsers()
            
			DispatchQueue.main.async {[weak self] in
				self?.isLoadingTrx = false
				self?.isError = false
				self?.error = nil


				self?.isShowAddCoin.toggle()
				DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
					self?.isTransactionSucceed.toggle()
				}
				self?.productSelected = nil

			}
		case .failure(let failure):
			handleDefaultErrorCoinVerify(error: failure)
		}
    }

	func handleDefaultErrorFreePayment(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoading = false
			self?.isShowSessionDetail = false

			if let error = error as? ErrorResponse {
				self?.error = error.message.orEmpty()


				if error.statusCode.orZero() == 401 {
					self?.isRefreshFailed.toggle()
          self?.alert.isError = true
          self?.alert.message = LocalizableText.alertSessionExpired
          self?.alert.primaryButton = .init(
            text: LocalizableText.okText,
            action: { self?.backToRoot() }
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

	func onSendFreePayment() {
		Task {
			await sendFreePayment()
		}
	}
	
    func sendFreePayment() async {
        onStartedFetch(isRecommend: false)
        let params = BookingPaymentRequest(
            paymentMethod: 99,
			meetingId: sessionCard.id.orEmpty().isEmpty ? nil : sessionCard.id,
            meetingBundleId: sessionCard.meetingBundleId.orEmpty().isEmpty ? nil : sessionCard.meetingBundleId.orEmpty()
        )

		let result = await bookingPaymentUseCase.execute(with: params)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				withAnimation {
					self?.success = true
					self?.isLoading = false
					self?.isShowSessionDetail = false
					self?.isFreeBookingSucceed = true
          
          let viewModel = InvoicesBookingViewModel(bookingId: (success.bookingPayment?.bookingID).orEmpty(), backToRoot: self?.backToRoot ?? {}, backToHome: {self?.route = nil}, backToChoosePayment: {self?.route = nil})
          
          DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self?.route = .bookingInvoice(viewModel: viewModel)
          }
				}
			}
		case .failure(let failure):
			handleDefaultErrorFreePayment(error: failure)
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
