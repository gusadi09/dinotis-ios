//
//  BundlingDetailViewModel.swift
//  DinotisApp
//
//  Created by Garry on 30/09/22.
//

import Foundation
import Combine
import UIKit
import DinotisData
import StoreKit
import DinotisDesignSystem
import OneSignal

final class BundlingDetailViewModel: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

	private let bundlingRepository: BundlingRepository
	private let authRepository: AuthenticationRepository
	private let getUserUseCase: GetUserUseCase
	private let coinVerificationUseCase: CoinVerificationUseCase
	private let coinPaymentUseCase: CoinPaymentUseCase
	private let promoCodeCheckingUseCase: PromoCodeCheckingUseCase
	private let extraFeeUseCase: GetExtraFeeUseCase
	private let bookingPaymentUseCase: BookingPaymentUseCase
	private let bundleId: String

	private var cancellables = Set<AnyCancellable>()
	private var stateObservable = StateObservable.shared
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
    
    var backToHome: () -> Void
    
    @Published var route: HomeRouting?
	@Published var talentName: String
	@Published var talentPhoto: String
	@Published var isTalentVerified: Bool
	@Published var isActive: Bool

	@Published var isLoading = false
	@Published var isError = false
	@Published var error: String?
	@Published var isRefreshFailed = false
  
  @Published var isShowAlert = false
  @Published var alert = AlertAttribute()

	@Published var detailData: DetailBundlingResponse?
	@Published var meetingData = [MeetingDetailResponse]()
    @Published var meetingIdArray = [String]()

	@Published var profileDetailBundle: [GeneralMeetingData]
    
    @Published var isTalent: Bool

    @Published var meetingId = ""
    
    @Published var goToEdit = false

	@Published var userData: UserResponse?

	@Published var isPresent = false
	@Published var showPaymentMenu = false
	@Published var isShowCoinPayment = false
	@Published var showAddCoin = false
	@Published var isTransactionSucceed = false
    
    @Published var isShowDelete = false
  @Published var meetingForm = MeetingForm(id: String.random(), title: "", description: "", price: 0, startAt: "", endAt: "", isPrivate: true, slots: 0, urls: [])

	@Published var promoCodeSuccess = false
	@Published var promoCodeError = false
	@Published var promoCodeData: PromoCodeResponse?
	@Published var isPromoCodeLoading = false

	@Published var promoCode = ""
	@Published var invoiceNumber = ""

	@Published var isLoadingCoinPay = false

	@Published var promoCodeTextArray = [String]()

	@Published var totalPayment = 0
	@Published var extraFee = 0
	@Published var price = ""

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
	@Published var isLoadingTrxs = false
	@Published var productSelected: SKProduct? = nil

	@Published var freeTrans = false
    
    init(
		bundlingRepository: BundlingRepository = BundlingDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		getUserUseCase: GetUserUseCase = GetUserDefaultUseCase(),
		coinVerificationUseCase: CoinVerificationUseCase = CoinVerificationDefaultUseCase(),
		coinPaymentUseCase: CoinPaymentUseCase = CoinPaymentDefaultUseCase(),
		promoCodeCheckingUseCase: PromoCodeCheckingUseCase = PromoCodeCheckingDefaultUseCase(),
		extraFeeUseCase: GetExtraFeeUseCase = GetExtraFeeDefaultUseCase(),
		bookingPaymentUseCase: BookingPaymentUseCase = BookingPaymentDefaultUseCase(),
		talentName: String = "",
		talentPhoto: String = "",
		isTalentVerified: Bool = false,
		bundleId: String,
		profileDetailBundle: [GeneralMeetingData] = [],
        meetingIdArray: [String],
        backToHome: @escaping (() -> Void),
        isTalent: Bool,
		isActive: Bool
    ) {
		self.profileDetailBundle = profileDetailBundle
		self.bundlingRepository = bundlingRepository
		self.authRepository = authRepository
		self.bundleId = bundleId
        self.meetingIdArray = meetingIdArray
        self.backToHome = backToHome
        self.isTalent = isTalent
		self.talentName = talentName
		self.talentPhoto = talentPhoto
		self.isTalentVerified = isTalentVerified
		self.getUserUseCase = getUserUseCase
		self.coinVerificationUseCase = coinVerificationUseCase
		self.coinPaymentUseCase = coinPaymentUseCase
		self.isActive = isActive
		self.promoCodeCheckingUseCase = promoCodeCheckingUseCase
		self.extraFeeUseCase = extraFeeUseCase
		self.bookingPaymentUseCase = bookingPaymentUseCase
    }
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false

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
                        OneSignal.setExternalUserId("")
                    }
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
		onStartRequest()
        
        let result = await getUserUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.userData = success
                self?.stateObservable.userId = success.id.orEmpty()
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
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

	func handleDefaultErrorCoinVerify(error: Error) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoadingTrxs = false
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
				}
			} else {
				self?.isError = true
				self?.error = error.localizedDescription
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
        primaryButton: .init(text: LocalizableText.closeLabel, action: {}),
        secondaryButton: nil
      )
		}
	}

    func coinPayment(onSuccess: @escaping () -> Void) async {
		onStartPay()

		let coin = CoinPaymentRequest(meetingId: nil, voucherCode: promoCode.isEmpty ? nil : promoCode, meetingBundleId: (detailData?.id).orEmpty())

		let result = await coinPaymentUseCase.execute(with: coin)

		switch result {
		case .success(_):
            await self.getUsers()
			DispatchQueue.main.async { [weak self] in
				self?.showPaymentMenu = false
				self?.isShowCoinPayment = false
				self?.showAddCoin = false
                self?.isTransactionSucceed = false
                self?.isLoadingCoinPay = false
                self?.isShowAlert = true
                
                self?.alert.isError = false
                self?.alert.title = LocalizableText.alertSuccessBookingTitle
                self?.alert.message = LocalizableText.alertSuccessBookingMessage
                self?.alert.primaryButton = .init(
                    text: LocalizableText.seeAgendaLabel,
                    action: {
                        self?.backToHome()
                        onSuccess()
                    }
                )
            }
        case .failure(let failure):
            handleDefaultErrorCoinPayment(error: failure) {
                Task {
                    await self.coinPayment(onSuccess: onSuccess)
                }
            }
        }
	}

  func handleDefaultErrorCoinPayment(error: Error, retry: @escaping () -> Void) {
		DispatchQueue.main.async { [weak self] in
			self?.isLoadingCoinPay = false
			self?.showPaymentMenu = false
			self?.isShowCoinPayment = false
			self?.showAddCoin = false
			self?.isTransactionSucceed = false

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
          self?.alert.title = LocalizableText.alertFailedBookingTitle
          self?.alert.message = LocalizableText.alertFailedBookingMessage
          self?.alert.primaryButton = .init(
            text: LocalizableText.resendLabel,
            action: retry
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
        self?.alert.isError = true
        self?.alert.message = error.localizedDescription
        self?.isShowAlert = true
			}

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
						} catch {
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
					self?.isLoadingTrxs = false
					self?.isError.toggle()
					self?.error = LocaleText.inAppsPurchaseTrx
				}
			default:
				queue.finishTransaction(transaction)
			}
		}
	}

	func onDisappear() {
		SKPaymentQueue.default().remove(self)
	}

	func purchaseProduct(product: SKProduct) {
		if SKPaymentQueue.canMakePayments() {
			SKPaymentQueue.default().add(self)
			let payment = SKPayment(product: product)
			SKPaymentQueue.default().add(payment)

		} else {
			DispatchQueue.main.async {[weak self] in
				self?.isError.toggle()
				self?.error = LocaleText.inAppsPurchaseTrx
			}

		}
	}

	func request(_ request: SKRequest, didFailWithError error: Error) {
		DispatchQueue.main.async {[weak self] in
			self?.isError.toggle()
			self?.error = error.localizedDescription
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

	func getProducts(productIDs: [String]) {
		let request = SKProductsRequest(productIdentifiers: Set(productIDs))
		request.delegate = self
		request.start()
	}

	func getProductOnAppear() {
		getProducts(productIDs: productIDs)
	}

	func openWhatsApp() {
		if let waurl = URL(string: "https://wa.me/6281318506068") {
			if UIApplication.shared.canOpenURL(waurl) {
				UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
			}
		}
	}

	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.isRefreshFailed = false
			self?.freeTrans = false
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

	func resetStateCode() {
		DispatchQueue.main.async { [weak self] in
			self?.promoCode = ""
			self?.promoCodeError = false
			self?.promoCodeSuccess = false
			self?.promoCodeData = nil
			self?.promoCodeTextArray = []
			self?.totalPayment = Int((self?.price).orEmpty()).orZero() + (self?.extraFee).orZero()
		}
	}
    
    func getAvailableMeeting() {
        onStartRequest()
        
        bundlingRepository.provideGetAvailableMeeting()
            .sink { result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        if error.statusCode.orZero() == 401 {
                            
                        } else {
                            self?.isLoading = false
                            self?.isError = true

                            self?.error = error.message.orEmpty()
                        }
                    }
                case .finished:
                    DispatchQueue.main.async { [weak self] in
                        self?.isLoading = false
                    }
                }
            } receiveValue: { value in
                self.meetingData = (value.data?.filter({ item in
                    self.meetingIdArray.contains {
                        $0 == item.id.orEmpty()
                    }
                }) ?? [])
            }
            .store(in: &cancellables)

    }

	func getBundleDetail() {
		onStartRequest()

		bundlingRepository.provideGetDetailBundling(by: bundleId)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							
						} else {
							self?.isLoading = false
							self?.isError = true

							self?.error = error.message.orEmpty()
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.isLoading = false
					}
				}
			} receiveValue: { response in
				DispatchQueue.main.async {[weak self] in
					self?.detailData = response
					self?.meetingData = response.meetings ?? []
					self?.price = response.price.orEmpty()
                    print("Response: ", response)
				}

			}
			.store(in: &cancellables)
	}

    func onAppear(isPreview: Bool) {
		DispatchQueue.main.async {[weak self] in
            if isPreview {
                self?.getAvailableMeeting()
            } else {
                self?.getBundleDetail()
            }
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
    
    func routeToTalentDetailSchedule() {
        let viewModel = ScheduleDetailViewModel(isActiveBooking: true, bookingId: meetingId, backToHome: self.backToHome, isDirectToHome: false)
        
        DispatchQueue.main.async { [weak self] in
            self?.route = .talentScheduleDetail(viewModel: viewModel)
        }
    }

	func routeToUserScheduleDetail() {
        let viewModel = ScheduleDetailViewModel(isActiveBooking: true, bookingId: meetingId, backToHome: self.backToHome, isDirectToHome: false)

		DispatchQueue.main.async { [weak self] in
			self?.route = .userScheduleDetail(viewModel: viewModel)
		}
	}

	func routeToEditSchedule() {
		let viewModel = EditTalentMeetingViewModel(meetingID: meetingId, backToHome: self.backToHome)

		DispatchQueue.main.async {[weak self] in
			self?.route = .editScheduleMeeting(viewModel: viewModel)
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
                OneSignal.setExternalUserId("")}
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

	func onSendFreePayment() {
		Task {
			await sendFreePayment()
		}
	}

	func onPaymentTypeOption() {
		Task {
			await extraFees()

			DispatchQueue.main.async { [weak self] in
				self?.isShowCoinPayment.toggle()
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
					if success.discountTotal.orZero() > (Int(self?.price ?? "").orZero() + (self?.extraFee).orZero()) {
						self?.totalPayment = 0
					} else {
						self?.totalPayment = Int(self?.price ?? "").orZero() + (self?.extraFee).orZero() - success.discountTotal.orZero()
					}
				} else if success.amount.orZero() != 0 && success.discountTotal.orZero() == 0 {
					if success.amount.orZero() > (Int(self?.price ?? "").orZero() + (self?.extraFee).orZero()) {
						self?.totalPayment = 0
					} else {
						self?.totalPayment = Int(self?.price ?? "").orZero() + (self?.extraFee).orZero() - success.amount.orZero()
					}
				}

				self?.promoCodeTextArray = success.defineDiscountString()
			}
		case .failure(let failure):
			handleDefaultErrorPromoCodeChecking(error: failure)
		}
	}

	func extraFees() async {
		onStartRequest()

		let body = PaymentExtraFeeRequest(meetingId: nil, meetingBundleId: (detailData?.id).orEmpty())

		let result = await extraFeeUseCase.execute(by: body)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.extraFee = success

				self?.totalPayment = success + Int((self?.price).orEmpty()).orZero()

				self?.isLoading = false
			}
		case .failure(let failure):
			handleDefaultErrorFreePayment(error: failure)
		}
	}

	func sendFreePayment() async {
		onStartRequest()
		let params = BookingPaymentRequest(paymentMethod: 99, meetingId: nil, meetingBundleId: (detailData?.id).orEmpty())

		let result = await bookingPaymentUseCase.execute(with: params)

		switch result {
		case .success(_):
			DispatchQueue.main.async { [weak self] in
				self?.freeTrans = true
				self?.isLoading = false
			}
		case .failure(let failure):
			handleDefaultErrorFreePayment(error: failure)
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
				self?.error = error.localizedDescription
        self?.alert.isError = true
        self?.alert.message = error.localizedDescription
        self?.isShowAlert = true
			}

		}
	}
}
