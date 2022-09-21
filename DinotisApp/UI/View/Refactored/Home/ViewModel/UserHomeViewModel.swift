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
import StoreKit
import OneSignal

final class UserHomeViewModel: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

	var backToRoot: () -> Void
	
	private var stateObservable = StateObservable.shared
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
	private let userRepository: UsersRepository
	private let talentRepository: TalentRepository
	
	private let authRepository: AuthenticationRepository
	private let professionRepository: ProfessionRepository
	private let homeRepository: HomeRepository
	private let coinRepository: CoinRepository

	@Published var latestNotice = [LatestNoticeResponse]()
	@Published var selectedCategory = ""
	@Published var selectedCategoryId = 0
	@Published var selectedProfession = 0
	@Published var currentPage = 0
	
	@Published var route: HomeRouting?
	
	@Published var username: String?
	@Published var showingPasswordAlert = false
	
	@Published var isLoading = false
	
	@Published var userData: Users?
	
	@Published var profession = [ProfessionProfession]()
	@Published var privateScheduleContent = [UserMeeting]()
	@Published var groupScheduleContent = [UserMeeting]()
	
	private var cancellables = Set<AnyCancellable>()
	
	@Published var isError: Bool = false
	@Published var error: HMError?
	@Published var success: Bool = false
	
	@Published var homeContent = [DynamicHomeData]()
	@Published var originalSectionContent: OriginalSectionResponse?
	
	@Published var isRefreshFailed = false
	
	@Published var takeItem = 30
	
	@Published var skip = 0
	
	@Published var nextCursor = 0
	
	@Published var photoProfile: String?
	
	@Published var nameOfUser: String?
	
	@Published var firstBanner = [Banner]()
	@Published var firstBannerContents = [BannerImage]()
	
	@Published var secondBanner = [Banner]()
	@Published var secondBannerContents = [BannerImage]()
	
	@Published var categoryData: CategoriesResponse?
	
	@Published var trendingData = [Talent]()
	
	@Published var reccomendData = [Talent]()
	
	@Published var isSearchLoading = false
	
	@Published var searchResult = [Talent]()

	@Published var announceData = [AnnouncementData]()
	@Published var announceIndex = 0

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
	
	init(
		backToRoot: @escaping (() -> Void),
		userRepository: UsersRepository = UsersDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		professionRepository: ProfessionRepository = ProfessionDefaultRepository(),
		talentRepository: TalentRepository = TalentDefaultRepository(),
		homeRepository: HomeRepository = HomeDefaultRepository(),
		coinRepository: CoinRepository = CoinDefaultRepository()
	) {
		self.backToRoot = backToRoot
		self.userRepository = userRepository
		self.authRepository = authRepository
		self.professionRepository = professionRepository
		self.talentRepository = talentRepository
		self.homeRepository = homeRepository
		self.coinRepository = coinRepository
	}

	func onDisappear() {
		SKPaymentQueue.default().remove(self)
	}

	func openWhatsApp() {
		if let waurl = URL(string: "https://wa.me/6281318506068") {
			if UIApplication.shared.canOpenURL(waurl) {
				UIApplication.shared.open(waurl, options: [:], completionHandler: nil)
			}
		}
	}

	func routeToCoinHistory() {
		let viewModel = CoinHistoryViewModel(backToHome: { self.route = nil }, backToRoot: self.backToRoot)

		DispatchQueue.main.async { [weak self] in
			self?.route = .coinHistory(viewModel: viewModel)
		}
	}

	func verifyCoin(receipt: String, queue: SKPaymentQueue, transaction: SKPaymentTransaction) {

		coinRepository.providePostVerifyCoin(with: receipt)
			.sink { result in
				switch result {
				case .failure(let error):
					if error.statusCode.orZero() == 401 {
						self.refreshToken(onComplete: {
							self.verifyCoin(receipt: receipt, queue: queue, transaction: transaction)
						})
					} else {
						queue.finishTransaction(transaction)

						DispatchQueue.main.async {[weak self] in
							self?.isLoadingTrx = false
							self?.isError = true
							self?.error = .clientError(code: error.statusCode.orZero(), message: error.error.orEmpty())
							self?.productSelected = nil
						}
					}

				case .finished:
					DispatchQueue.main.async {[weak self] in
						self?.isLoadingTrx = false
						self?.isError = false
						self?.error = nil

						queue.finishTransaction(transaction)
						self?.isTransactionSucceed.toggle()
						self?.showAddCoin = false
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
					self?.isLoadingTrx = true
					self?.isError = false
					self?.error = nil
				}
				transactionState = .purchasing
			case .purchased:

				transactionState = .purchased

				if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
					 FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {

					do {
						let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
						print(receiptData)

						let receiptString = receiptData.base64EncodedString(options: [])

						self.verifyCoin(receipt: receiptString, queue: queue, transaction: transaction)
					}
					catch {
						DispatchQueue.main.async {[weak self] in
							self?.isLoadingTrx = false
							self?.isError.toggle()
							self?.error = HMError.custom(message: error.localizedDescription)
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
				isTransactionSucceed.toggle()
				showAddCoin = false
				productSelected = nil
			case .failed, .deferred:
				transactionState = .failed
				DispatchQueue.main.async {[weak self] in
					self?.isLoadingTrx = false
					self?.isError.toggle()
					self?.error = HMError.custom(message: LocaleText.inAppsPurchaseTrx)
				}
			default:
				queue.finishTransaction(transaction)
			}
		}
	}

	func purchaseProduct(product: SKProduct) {
		SKPaymentQueue.default().add(self)
		
		if SKPaymentQueue.canMakePayments() {
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
	
	func errorText() -> String {
		(error?.errorDescription).orEmpty()
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
	
	func onScreenAppear(geo: GeometryProxy) async {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			self.isTransactionSucceed = false
			self.getGroupFeatureCall()
			self.getUsers()
			self.getLatestNotice()
			self.getAllProfession()
			self.getCategory()
			self.getFirstBanner(geo: geo)
			self.getSecondBanner(geo: geo)
			self.selectedCategoryId = 0
			self.selectedCategory = ""
			self.getAllTalents()
			self.getHomeContent()
			self.getPrivateFeatureCall()
			self.getAnnouncement()
			self.getOriginalSection()
		}
	}

	func getProductOnAppear() {
		getProducts(productIDs: productIDs)
	}
	
	func routeBack() {
		if (error?.errorDescription).orEmpty().contains("401") {
			backToRoot()
			stateObservable.userType = 0
			stateObservable.isVerified = ""
			stateObservable.refreshToken = ""
			stateObservable.accessToken = ""
			stateObservable.isAnnounceShow = false
			OneSignal.setExternalUserId("")
		}
	}
	
	func routeToProfile() {
		let viewModel = ProfileViewModel(backToRoot: backToRoot, backToHome: { self.route = nil })
		
		DispatchQueue.main.async { [weak self] in
			if self?.stateObservable.userType == 2 {
				self?.route = .talentProfile(viewModel: viewModel)
			} else {
				self?.route = .userProfile(viewModel: viewModel)
			}
		}
	}
	
	func routeToTalentProfile() {
		let viewModel = TalentProfileDetailViewModel(backToRoot: self.backToRoot, backToHome: {self.route = nil}, username: self.username.orEmpty())
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .talentProfileDetail(viewModel: viewModel)
		}
	}
	
	func routeToScheduleList() {
		let viewModel = ScheduleListViewModel(backToRoot: self.backToRoot, backToHome: {self.route = nil}, currentUserId: (userData?.id).orEmpty())
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .scheduleList(viewModel: viewModel)
		}
	}
	
	func onStartedFetch() {
		DispatchQueue.main.async {[weak self] in
			self?.isError = false
			self?.isLoading = true
			self?.error = nil
			self?.success = false
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
	
	func getAllTalents() {
		onStartedFetchSearch()
		
		let query = TalentQueryParams(
			query: "",
			skip: takeItem-30,
			take: takeItem,
			profession: nil,
			professionCategory: nil
		)
		
		talentRepository
			.provideGetSearchedTalent(with: query)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getCategory ?? {})
						} else {
							self?.isError = true
							self?.isSearchLoading = false
							
							self?.error = .serverError(code: error.statusCode.orZero(), message: error.message.orEmpty())
						}
					}
					
				case .finished:
					DispatchQueue.main.async { [weak self] in
						self?.success = true
						self?.isSearchLoading = false
					}
				}
			} receiveValue: { value in
				DispatchQueue.main.async { [weak self] in
					guard let self = self else { return }
					
					for items in value.data {
						self.searchResult.append(items)
					}
					
					let temp = self.searchResult.unique()
					
					self.searchResult = temp
					
					self.nextCursor = value.nextCursor.orZero()
				}
				
			}
			.store(in: &cancellables)
	}
	
	func getAllProfession() {
		onStartedFetch()
		
		professionRepository.provideGetProfession()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getAllProfession ?? {})
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
				self.profession = value.data ?? []
			}
			.store(in: &cancellables)
	}

	func getOriginalSection() {
		onStartedFetch()

		homeRepository.provideGetOriginalSection()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getOriginalSection ?? {})
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
				self.originalSectionContent = value
			}
			.store(in: &cancellables)
	}

	func getLatestNotice() {
		onStartedFetch()

		homeRepository.provideGetLatestNotice()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getLatestNotice ?? {})
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
				self.latestNotice = value
			}
			.store(in: &cancellables)
	}
	
	func getPrivateFeatureCall() {
		onStartedFetch()

		DispatchQueue.main.async {
			self.privateScheduleContent = []
		}
		
		homeRepository.provideGetPrivateCallFeature()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getPrivateFeatureCall ?? {})
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
				self.privateScheduleContent = value.data ?? []
			}
			.store(in: &cancellables)
	}

	func getGroupFeatureCall() {
		onStartedFetch()

		DispatchQueue.main.async {
			self.groupScheduleContent = []
		}

		homeRepository.provideGetGroupCallFeature()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getPrivateFeatureCall ?? {})
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
				self.groupScheduleContent = value.data ?? []
			}
			.store(in: &cancellables)
	}
	
	func getHomeContent() {
		onStartedFetch()

		DispatchQueue.main.async {
			self.homeContent = []
		}
		
		homeRepository.provideGetDynamicHome()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getHomeContent ?? {})
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
				self.homeContent = value.data ?? []
			}
			.store(in: &cancellables)
	}
	
	func getSecondBanner(geo: GeometryProxy) {
		onStartedFetch()

		DispatchQueue.main.async {[self] in
			firstBannerContents = []
			secondBannerContents = []
		}
		
		homeRepository.provideGetSecondBanner()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.getFirstBanner(geo: geo)
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
				self.secondBanner = value.data ?? []

				var temp = [BannerImage]()
				
				for item in value.data ?? [] {
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

				self.secondBannerContents = temp
			}
			.store(in: &cancellables)
	}
	
	func getFirstBanner(geo: GeometryProxy) {
		onStartedFetch()

		DispatchQueue.main.async { [self] in
			firstBannerContents = []
			secondBannerContents = []
		}
		
		homeRepository.provideGetFirstBanner()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.getFirstBanner(geo: geo)
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
				self.firstBanner = value.data ?? []

				var temp = [BannerImage]()

				for item in value.data ?? [] {
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

				self.firstBannerContents = temp
			}
			.store(in: &cancellables)
	}
	
	func getCategory() {
		onStartedFetch()
		
		professionRepository
			.provideGetCategory()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getCategory ?? {})
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
				self.categoryData = value
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
				self.nameOfUser = value.name
				self.photoProfile = value.profilePhoto
				OneSignal.setExternalUserId(value.id.orEmpty())
				OneSignal.sendTag("isTalent", value: "false")
				
				withAnimation {
					self.showingPasswordAlert = !(value.isPasswordFilled ?? false)
				}
			}
			.store(in: &cancellables)
		
	}
	
	func getTrendingTalent() {
		onStartedFetch()
		
		let query = TalentQueryParams(query: "", skip: 0, take: 30)
		
		talentRepository
			.provideGetCrowdedTalent(with: query)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getTrendingTalent ?? {})
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
				self.trendingData = value.data
			}
			.store(in: &cancellables)
		
	}

	func getAnnouncement() {
		onStartedFetch()

		homeRepository
			.provideGetAnnouncementBanner()
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getAnnouncement ?? {})
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
				self.announceData = value.data ?? []
			}
			.store(in: &cancellables)

	}
	
	func getRecommendTalent() {
		onStartedFetch()
		
		let query = TalentQueryParams(query: "", skip: 0, take: 10)
		
		talentRepository
			.provideGetRecommendationTalent(with: query)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: self?.getRecommendTalent ?? {})
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
				self.reccomendData = value.data
			}
			.store(in: &cancellables)
		
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
	
	func routeToSearch() {
		let viewModel = SearchTalentViewModel(
			backToRoot: self.backToRoot,
			backToHome: {self.route = nil},
			categorySelectedName: self.selectedCategory,
			categorySelectedId: self.selectedCategoryId
		)
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .searchTalent(viewModel: viewModel)
		}
	}
	
	func routeToReset() {
		let viewModel = LoginPasswordResetViewModel(isFromHome: true, backToRoot: self.backToRoot, backToLogin: {})
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .loginResetPassword(viewModel: viewModel)
		}
	}
}

extension SKProduct: Identifiable {
	
}
