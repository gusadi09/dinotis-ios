//
//  CoinHistoryViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 20/06/22.
//

import Combine
import UIKit
import OneSignal
import DinotisData
import DinotisDesignSystem

final class CoinHistoryViewModel: ObservableObject {

	private let coinHistoryUseCase: CoinHistoryUseCase
	private let authRepository: AuthenticationRepository
	private var cancellables = Set<AnyCancellable>()

	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?

	private var stateObservable = StateObservable.shared

	var backToHome: (() -> Void)

	@Published var error: String?
	@Published var isLoading = false
	@Published var isError = false
  
  @Published var isShowAlert = false
  @Published var alert = AlertAttribute()

	@Published var success = false

	@Published var isRefreshFailed = false

	@Published var coinHistoryData = [CoinHistoryData]()
	@Published var currentData = [CoinHistoryData]()

	@Published var tabSelection = LocaleText.allText
	@Published var historyQuery = GeneralParameterRequest(skip: 0, take: 15)

	init(
		coinHistoryUseCase: CoinHistoryUseCase = CoinHistoryDefaultUseCase(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
		backToHome: @escaping (() -> Void)
	) {
		self.coinHistoryUseCase = coinHistoryUseCase
		self.authRepository = authRepository
		self.backToHome = backToHome
	}

	func routeBack() {
		if error.orEmpty().contains("401") {
            NavigationUtil.popToRootView()
            self.stateObservable.userType = 0
            self.stateObservable.isVerified = ""
            self.stateObservable.refreshToken = ""
            self.stateObservable.accessToken = ""
            self.stateObservable.isAnnounceShow = false
            OneSignal.setExternalUserId("")
		}
	}

	func errorText() -> String {
		self.error.orEmpty()
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
		}

		await self.getCoinHistory()
	}

	func onStartFetch() {
		DispatchQueue.main.async { [weak self] in
			self?.isError = false
			self?.error = nil
			self?.isLoading = true
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

	func onStartRefresh() {
        DispatchQueue.main.async { [weak self] in
            self?.isRefreshFailed = false
            self?.isLoading = true
            self?.success = false
            self?.error = nil
            self?.isError = false
        }
	}

	func handleDefaultErrorHistory(error: Error) {
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

	func getCoinHistory() async {
		onStartFetch()

		let result = await coinHistoryUseCase.execute(by: historyQuery)

		switch result {
		case .success(let success):
			DispatchQueue.main.async { [weak self] in
				self?.success = true
				self?.isLoading = false

				self?.coinHistoryData += (success.data ?? []).filter({ item in
					item.isSuccess ?? false
				})
				self?.currentData = (success.data ?? []).filter({ item in
					item.isSuccess ?? false
				})
			}
		case .failure(let failure):
			handleDefaultErrorHistory(error: failure)
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
