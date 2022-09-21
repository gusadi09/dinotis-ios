//
//  SearchTalentViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 03/03/22.
//

import Foundation
import Combine
import UIKit

final class SearchTalentViewModel: ObservableObject {
	
	var backToRoot: () -> Void
	var backToHome: () -> Void
	
	private var stateObservable = StateObservable.shared
	
	private var timer: Timer?
	
	private let professionRepository: ProfessionRepository
	private let authRepository: AuthenticationRepository
	private let talentRepository: TalentRepository
	
	private var cancellables = Set<AnyCancellable>()
	
	@Published var route: HomeRouting?
	
	@Published var searchText = ""
	
	@Published var categorySelectedName: String
	@Published var categorySelectedId: Int
	
	@Published var categoryData = [Categories]()
	
	@Published var professionDataByCategory = [ProfessionProfession]()
	@Published var professionData = [ProfessionProfession]()
	
	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: HMError?
	
	@Published var isRefreshFailed = false
	
	@Published var professionSelect = ""
	
	@Published var professionId = 0
	
	@Published var takeItem = 30
	
	@Published var skip = 0
	
	@Published var nextCursor = 0
	
	@Published var searchResult = [Talent]()
	@Published var trendingResult = [Talent]()
	@Published var isSearchLoading = false
	@Published var username: String?
	
	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		categorySelectedName: String = "",
		categorySelectedId: Int = 0,
		professionRepository: ProfessionRepository = ProfessionDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		talentRepository: TalentRepository = TalentDefaultRepository()
	) {
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.categorySelectedId = categorySelectedId
		self.categorySelectedName = categorySelectedName
		self.professionRepository = professionRepository
		self.authRepository = authRepository
		self.talentRepository = talentRepository
		
	}
	
	func routeToTalentProfile() {
		let viewModel = TalentProfileDetailViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome, username: self.username.orEmpty())
		
		DispatchQueue.main.async { [weak self] in
			self?.route = .talentProfileDetail(viewModel: viewModel)
		}
	}
	
	func onViewDisappear() {
		searchText = ""
		categorySelectedId = 0
		categorySelectedName = ""
	}
	
	func isCategoriesShow() -> Bool {
		categorySelectedName.isEmpty && searchText.isEmpty
	}
	
	func onCancelSearch() {
		searchText = ""
		categorySelectedName = ""
		categorySelectedId = 0
		professionId = 0
		professionSelect = ""
		UIApplication.shared.endEditing()
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
	
	func startCheckingTimer() {
		if let timer = timer {
			timer.invalidate()
		}
		
		onStartedFetchSearch()
		
		timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(searchTalent), userInfo: nil, repeats: false)
	}
	
	@objc func searchTalent() {
		onStartedFetchSearch()
		
		let query = TalentQueryParams(
			query: searchText.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed).orEmpty(),
			skip: takeItem-30,
			take: takeItem,
			profession: professionId,
			professionCategory: categorySelectedId
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
				for items in value.data {
					self.searchResult.append(items)
				}
				
				let temp = self.searchResult.unique()
				
				self.searchResult = temp
				
				self.nextCursor = value.nextCursor.orZero()
			}
			.store(in: &cancellables)
		
	}
	
	func getProfessionByCategory() {
		onStartedFetch()
		
		professionRepository
			.provideGetProfessionByCategory(with: categorySelectedId)
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
				self.professionDataByCategory = value.data ?? []
			}
			.store(in: &cancellables)
	}
	
	func getProfession() {
		onStartedFetch()
		
		professionRepository
			.provideGetProfession()
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
				self.professionData = value.data ?? []
			}
			.store(in: &cancellables)
	}
	
	func getTrendingByCategory() {
		onStartedFetch()
		
		let query = TalentQueryParams(query: "", skip: 0, take: 30, profession: professionId, professionCategory: categorySelectedId)
		
		talentRepository
			.provideGetCrowdedTalent(with: query)
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
				self.trendingResult = value.data
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
				self.categoryData = value.data ?? []
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
	
}
