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

final class TalentProfileDetailViewModel: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	private let coinRepository: CoinRepository

	@Published var filterSelection = "Jadwal Yang Tersedia"
	
	@Published var route: HomeRouting?

	@Published var showingRequest = false
	
	@Published var showMenuCard = false
	
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: HMError?
	
	@Published var methodName = ""
	@Published var methodIcon = ""
	
	@Published var isRefreshFailed = false
	@Published var freeTrans = false

	@Published var redirectUrl: String?
	@Published var qrCodeUrl: String?

	private let authRepository: AuthenticationRepository
	private let talentRepository: TalentRepository
	private let userRepository: UsersRepository
	private var cancellables = Set<AnyCancellable>()
	private let meetRepository: MeetingsRepository
	private let paymentRepository: PaymentRepository
	@Published var config = Configuration.shared

	@Published var userData: Users?
	@Published var userName: String?
	@Published var userPhoto: String?

	@Published var talentData: TalentFromSearch?
	@Published var talentName: String?
	@Published var talentPhoto: String?

	@Published var profileBanner = [Highlights]()
	@Published var profileBannerContent = [ProfileBannerImage]()

	@Published var countPart = 0
	@Published var totalPart = 0
	@Published var title = ""
	@Published var desc = ""
	@Published var date = ""
	@Published var timeStart = ""
	@Published var timeEnd = ""
	@Published var price = ""
	@Published var meetingId = ""
	@Published var textJob = Text("")

	@Published var totalPayment = 0
	@Published var extraFee = 0

	@Published var isPresent = false
	@Published var bookingId = ""
	@Published var filterOption = [OptionQuery]()
	@Published var meetingData = [Meeting]()

	@Published var payments = UserBookingPayment(
		id: "",
		amount: "",
		bookingID: "",
		paymentMethodID: 0,
		externalId: nil,
		redirectUrl: nil,
		qrCodeUrl: nil
	)

	@Published var meetingParam = MeetingsParams(take: 15, skip: 0, isStarted: "", isEnded: "false", isAvailable: "true")

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

	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		username: String,
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		talentRepository: TalentRepository = TalentDefaultRepository(),
		userRepository: UsersRepository = UsersDefaultRepository(),
		meetRepository: MeetingsRepository = MeetingsDefaultRepository(),
		coinRepository: CoinRepository = CoinDefaultRepository(),
		paymentRepository: PaymentRepository = PaymentDefaultRepository()
	) {
		self.username = username
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.authRepository = authRepository
		self.talentRepository = talentRepository
		self.userRepository = userRepository
		self.meetRepository = meetRepository
		self.coinRepository = coinRepository
		self.paymentRepository = paymentRepository
	}

	func onStartPay() {
		DispatchQueue.main.async { [weak self] in
			self?.isLoadingCoinPay = true
			self?.isError = false
			self?.error = nil
		}
	}

	func sendFreePayment() {
		onStartedFetch()
		let params = BookingPay(paymentMethod: 99, meetingId: self.meetingId)

		paymentRepository
			.provideSendBookingPayment(by: params)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.sendFreePayment ?? {})
						} else {
							self?.isError = true
							self?.isLoading = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						self?.freeTrans = true
						self?.isLoading = false
					}
				}
			} receiveValue: { response in
				
			}
			.store(in: &cancellables)

	}

	func coinPayment() {
		onStartPay()

		let coin = CoinPay(meetingId: meetingId, voucherCode: promoCode.isEmpty ? nil : promoCode)

		paymentRepository.provideSendPaymentCoin(by: coin)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.coinPayment ?? {})
						} else {
							self?.isError = true
							self?.isLoadingCoinPay = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.showPaymentMenu = false
						self?.isShowCoinPayment = false
						self?.showAddCoin = false
						self?.isTransactionSucceed = false
						self?.isLoadingCoinPay = false
						self?.getUsers()

						let viewModel = InvoicesBookingViewModel(backToRoot: self?.backToRoot ?? {}, backToHome: self?.backToHome ?? {})
						self?.route = .bookingInvoice(viewModel: viewModel)
					}

					Task {
						await self.onScreenAppear()
					}
				}
			} receiveValue: { response in
				self.invoiceNumber = response.bookingPayment.bookingID.orEmpty()
			}
			.store(in: &cancellables)

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

	func onStartCheckCode() {
		DispatchQueue.main.async { [weak self] in
			self?.promoCodeError = false
			self?.promoCodeSuccess = false
			self?.isPromoCodeLoading = true
			self?.promoCodeData = nil
			self?.promoCodeTextArray = []
		}
	}

	func checkPromoCode() {
		onStartCheckCode()

		let body = PromoCodeBody(code: promoCode, meetingId: meetingId, paymentMethodId: 10)

		paymentRepository.provideCheckPromoCode(by: body)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.checkPromoCode ?? {})
						} else {
							self?.promoCodeError = true
							self?.isLoading = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.promoCodeSuccess = true
						self?.isLoading = false
					}
				}
			} receiveValue: { value in
				self.promoCodeData = value

				if value.discountTotal.orZero() != 0 {
					if value.discountTotal.orZero() > (Int(self.price).orZero() + self.extraFee) {
						self.totalPayment = 0
					} else {
						self.totalPayment = Int(self.price).orZero() + self.extraFee - value.discountTotal.orZero()
					}
				} else if value.amount.orZero() != 0 && value.discountTotal.orZero() == 0 {
					if value.amount.orZero() > (Int(self.price).orZero() + self.extraFee) {
						self.totalPayment = 0
					} else {
						self.totalPayment = Int(self.price).orZero() + self.extraFee - value.amount.orZero()
					}
				}

				if value.percentageAmount.orZero() != 0 &&
						value.cashbackPercentageAmount.orZero() == 0 &&
						value.cashbackAmount.orZero() == 0 &&
						value.amount.orZero() == 0
				{
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))

				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() == 0 &&
										value.cashbackAmount.orZero() == 0 &&
										value.amount.orZero() != 0
				{
					self.promoCodeTextArray.append( LocaleText.discountCoinText("\(value.amount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() == 0 &&
										value.amount.orZero() == 0
				{
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() == 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() == 0
				{
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() != 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() == 0 &&
										value.amount.orZero() == 0
				{
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() == 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() != 0 {
					self.promoCodeTextArray.append(LocaleText.discountCoinText("\(value.amount.orZero())".toPriceFormat()))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() != 0 &&
										value.cashbackPercentageAmount.orZero() == 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() == 0 {
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() != 0 &&
										value.cashbackPercentageAmount.orZero() == 0 &&
										value.cashbackAmount.orZero() == 0 &&
										value.amount.orZero() != 0 {
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.discountCoinText("\(value.amount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() == 0 {
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() == 0 &&
										value.amount.orZero() != 0 {
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.discountCoinText("\(value.amount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() == 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() != 0 {
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
					self.promoCodeTextArray.append(LocaleText.discountCoinText("\(value.amount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() != 0 &&
										value.cashbackPercentageAmount.orZero() == 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() != 0 {
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
					self.promoCodeTextArray.append(LocaleText.discountCoinText("\(value.amount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() != 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() == 0 &&
										value.amount.orZero() != 0 {
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.discountCoinText("\(value.amount.orZero())".toPriceFormat()))
				} else if value.percentageAmount.orZero() != 0 &&
										value.cashbackPercentageAmount.orZero() != 0 &&
										value.cashbackAmount.orZero() != 0 &&
										value.amount.orZero() == 0 {
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
				} else {
					self.promoCodeTextArray.append(LocaleText.discountPercentageText("\(value.percentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackPercentageText("\(value.cashbackPercentageAmount.orZero())"))
					self.promoCodeTextArray.append(LocaleText.cashbackCoinText("\(value.cashbackAmount.orZero())".toPriceFormat()))
					self.promoCodeTextArray.append(LocaleText.discountCoinText("\(value.amount.orZero())".toPriceFormat()))
				}

			}
			.store(in: &cancellables)

	}

	func extraFees() {
		onStartedFetch()

		paymentRepository
			.provideExtraFee(with: meetingId)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.extraFees ?? {})
						} else {
							self?.isError = true
							self?.isLoading = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						self?.isLoading = false
					}
				}
			} receiveValue: { value in
				self.extraFee = value.extraFee.orZero()

				self.totalPayment = value.extraFee.orZero() + Int(self.price).orZero()
			}
			.store(in: &cancellables)

	}

	func openWhatsApp() {
		if let waurl = URL(string: "https://wa.me/6281318506068") {
			if UIApplication.shared.canOpenURL(waurl) {
				UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
			}
		}
	}

	func verifyCoin(receipt: String) {

		coinRepository.providePostVerifyCoin(with: receipt)
			.sink { result in
				switch result {
				case .failure(let error):
					if error.statusCode.orZero() == 401 {
						self.refreshToken(onComplete: {
							self.verifyCoin(receipt: receipt)
						})
					} else {

						DispatchQueue.main.async {[weak self] in
							self?.isLoadingTrxs = false
							self?.isError = true
							self?.error = .clientError(code: error.statusCode.orZero(), message: error.error.orEmpty())
							self?.productSelected = nil
						}
					}

				case .finished:
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
				}
			} receiveValue: { response in
				self.getUsers()
			}
			.store(in: &cancellables)

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

					do {
						let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
						print(receiptData)

						let receiptString = receiptData.base64EncodedString(options: [])

						self.verifyCoin(receipt: receiptString)
					}
					catch {
						DispatchQueue.main.async {[weak self] in
							self?.isLoadingTrxs = false
							self?.isError.toggle()
							self?.error = HMError.custom(message: error.localizedDescription)
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
					self?.error = HMError.custom(message: LocaleText.inAppsPurchaseTrx)
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
				self?.isError.toggle()
				self?.error = HMError.custom(message: LocaleText.inAppsPurchaseTrx)
			}

		}
	}

	func request(_ request: SKRequest, didFailWithError error: Error) {
		DispatchQueue.main.async {[weak self] in
			self?.isError.toggle()
			self?.error = HMError.custom(message: error.localizedDescription)
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

	@objc func onScreenAppear() async {
		getTalentFromSearch(by: username)
		getUsers()
	}

	func routeToRoot() {
		self.backToRoot()
		stateObservable.userType = 0
		stateObservable.isVerified = ""
		stateObservable.refreshToken = ""
		stateObservable.accessToken = ""
		stateObservable.isAnnounceShow = false
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
		}
	}

	func sendRequest(type: RequestScheduleType) {
		startSendRequest()

		let body = RequestScheduleBody(requestUserId: (userData?.id).orEmpty(), type: type.rawValue)

		talentRepository
			.provideSendRequestSchedule(
				talentId: (talentData?.id).orEmpty(),
				body: body
			)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.sendRequest(type: type)
							})
						} else {
							self?.requestError = true
							self?.isLoading = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.requestSuccess = true
						self?.isLoading = false
					}
				}
			} receiveValue: { _ in
				self.showingRequest = false
			}
			.store(in: &cancellables)
	}

	func onStartedFetch() {
		DispatchQueue.main.async {[weak self] in
			self?.isError = false
			self?.isLoading = true
			self?.error = nil
			self?.success = false
			self?.freeTrans = false
		}
	}

	func onStartRefresh() {
		self.isRefreshFailed = false
		self.isLoading = true
		self.success = false
		self.error = nil
	}

	func refreshToken(onComplete: @escaping (() -> Void)) {
		onStartRefresh()

		let refreshToken = authRepository.loadFromKeychain(forKey: KeychainKey.refreshToken)

		authRepository
			.refreshToken(with: refreshToken)
			.sink { result in
				switch result {
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						self?.isLoading = false
						onComplete()
					}

				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						self?.isRefreshFailed = true
						self?.isLoading = false
						self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
					}
				}
			} receiveValue: { value in
				self.stateObservable.refreshToken = value.refreshToken
				self.stateObservable.accessToken = value.accessToken
			}
			.store(in: &cancellables)
	}

	func getUsers() {
		onStartedFetch()

		userRepository
			.provideGetUsers()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getUsers ?? {})
						} else {
							self?.isError = true
							self?.isLoading = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						self?.isLoading = false
					}
				}
			} receiveValue: { value in
				self.userData = value
				self.userPhoto = value.profilePhoto
				self.userName = value.name
			}
			.store(in: &cancellables)

	}

	func getTalentFromSearch(by username: String) {
		onStartedFetch()

		talentRepository.provideGetDetailTalent(by: username)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.getTalentFromSearch(by: username)
							})
						} else {
							self?.isError = true
							self?.isLoading = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						self?.isLoading = false
					}
				}
			} receiveValue: { value in
				self.talentData = value
				self.talentPhoto = value.profilePhoto
				self.talentName = value.name
				self.getTalentMeeting(by: value.id)

				self.profileBanner = value.userHighlights ?? []
				var temp = [ProfileBannerImage]()

				if !(value.userHighlights ?? []).isEmpty {
					for item in value.userHighlights ?? [] {
						temp.append(
							ProfileBannerImage(
								content: item
							)
						)
					}

					self.profileBannerContent = temp
				}

			}
			.store(in: &cancellables)

	}

	func getTalentMeeting(by userId: String) {
		onStartedFetch()

		meetRepository.provideGetTalentDetailMeeting(userID: userId, params: meetingParam)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.getTalentMeeting(by: userId)
							})
						} else {
							self?.isError = true
							self?.isLoading = false

							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}

				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						self?.isLoading = false
					}
				}
			} receiveValue: { value in
				self.filterOption = value.filters?.options ?? []
				self.meetingData += value.data 

			}
			.store(in: &cancellables)

	}

	func routeToPaymentMethod(price: String, meetingId: String) {
		let viewModel = PaymentMethodsViewModel(price: price, meetingId: meetingId, backToRoot: self.backToRoot, backToHome: self.backToHome)

		DispatchQueue.main.async { [weak self] in
			self?.route = .paymentMethod(viewModel: viewModel)
		}
	}

	func routeToUserScheduleDetail() {
		let viewModel = ScheduleDetailViewModel(bookingId: bookingId, backToRoot: self.backToRoot, backToHome: self.backToHome)

		DispatchQueue.main.async { [weak self] in
			self?.route = .userScheduleDetail(viewModel: viewModel)
		}
	}

	func routeToManagement() {
		if let manageUsername = talentData?.userManagementTalent?.userManagement?.user.username {
			let viewModel = TalentProfileDetailViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome, username: manageUsername)
			
			DispatchQueue.main.async { [weak self] in
				self?.route = .talentProfileDetail(viewModel: viewModel)
			}
		}
	}

	func routeToMyTalent(talent: String) {
			let viewModel = TalentProfileDetailViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome, username: talent)

			DispatchQueue.main.async { [weak self] in
				self?.route = .talentProfileDetail(viewModel: viewModel)
			}
	}

	func isHaveMeeting(meet: Meeting, current: String) -> Bool {

		for itemsOfBook in meet.bookings.filter({ value in
			value.userID == current && value.bookingPayment?.failedAt == nil && value.bookingPayment?.paidAt != nil
		}) where current == itemsOfBook.userID {
			return true
		}

		return false
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
		Task.init {
			self.resetList()
			await onScreenAppear()
			self.onValueChanged?(sender)
		}
	}

	func resetList() {
		DispatchQueue.main.async {
			self.meetingParam.skip = 0
			self.meetingParam.take = 15
			self.meetingData = []

			self.getTalentMeeting(by: (self.talentData?.id).orEmpty())
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

}
