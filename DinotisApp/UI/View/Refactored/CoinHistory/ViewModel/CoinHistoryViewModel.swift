//
//  CoinHistoryViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import Foundation
import Combine
import UIKit
import OneSignal

final class CoinHistoryViewModel: ObservableObject {

	private let coinRepository: CoinRepository
	private let authRepository: AuthenticationRepository
	private var cancellables = Set<AnyCancellable>()

	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?

	private var stateObservable = StateObservable.shared

	var backToHome: (() -> Void)
	var backToRoot: (() -> Void)

	@Published var error: HMError?
	@Published var isLoading = false
	@Published var isError = false

	@Published var success = false

	@Published var isRefreshFailed = false

	@Published var coinHistoryData = [CoinHistoryData]()
	@Published var currentData = [CoinHistoryData]()

	@Published var tabSelection = LocaleText.allText
	@Published var historyQuery = CoinQuery(skip: 0, take: 10)

	init(
		coinRepository: CoinRepository = CoinDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		backToHome: @escaping (() -> Void),
		backToRoot: @escaping (() -> Void)
	) {
		self.coinRepository = coinRepository
		self.authRepository = authRepository
		self.backToHome = backToHome
		self.backToRoot = backToRoot
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

	func errorText() -> String {
		(self.error?.errorDescription).orEmpty()
	}

	func onAppeared() {
		Task {
			await onScreenAppear()
		}
	}

	func onScreenAppear() async {
		DispatchQueue.main.async { [weak self] in
			self?.historyQuery.take = 10
			self?.historyQuery.skip = 0
			self?.getCoinHistory()
		}

	}

	func onStartFetch() {
		DispatchQueue.main.async { [weak self] in
			self?.isError = false
			self?.error = nil
			self?.isLoading = true
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

	func getCoinHistory() {
		onStartFetch()

		coinRepository.provideGetCoinHistory(by: historyQuery)
			.sink { result in
				switch result {
				case .failure(let error):
					DispatchQueue.main.async {[weak self] in
						if error.statusCode.orZero() == 401 {
							self?.refreshToken(onComplete: {
								self?.getCoinHistory()
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
			} receiveValue: { response in
				self.coinHistoryData += (response.data ?? []).filter({ item in
					item.isSuccess ?? false
				})
				self.currentData = (response.data ?? []).filter({ item in
					item.isSuccess ?? false
				})
			}
			.store(in: &cancellables)

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

	func setEmptyData() {
		DispatchQueue.main.async {
			self.coinHistoryData = []
		}
	}

	@objc private func onValueChangedAction(sender: UIRefreshControl) {
		Task.init {
			self.setEmptyData()
			await onScreenAppear()
			self.onValueChanged?(sender)
		}
	}
}
