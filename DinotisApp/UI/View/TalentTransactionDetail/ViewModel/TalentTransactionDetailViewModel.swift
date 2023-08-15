//
//  TalentTransactionDetailViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/11/22.
//

import Foundation
import Combine
import OneSignal
import SwiftUI
import DinotisData

final class TalentTransactionDetailViewModel: ObservableObject {
	private let userRepository: UsersRepository
	private let authRepository: AuthenticationRepository
	private let getTransactionDetailUseCase: WithdrawalTransactionDetailUseCase
	private var cancellables = Set<AnyCancellable>()
	private var stateObservable = StateObservable.shared
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?

	var backToHome: () -> Void

	@Published var colorTab = Color.clear
	@Published var contentOffset: CGFloat = 0

	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?

	@Published var withdrawID: String

	@Published var withdrawData: WithdrawDetailResponse?

	@Published var route: HomeRouting?
	@Published var isRefreshFailed = false

	init(
		withdrawID: String,
		backToHome: @escaping (() -> Void),
		userRepository: UsersRepository = UsersDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        getTransactionDetailUseCase: WithdrawalTransactionDetailUseCase = WithdrawalTransactionDetailDefaultUseCase()
	) {
		self.withdrawID = withdrawID
		self.backToHome = backToHome
		self.userRepository = userRepository
		self.authRepository = authRepository
		self.getTransactionDetailUseCase = getTransactionDetailUseCase
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

	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.isRefreshFailed = false
		}

	}
    
    func handleDefaultError(error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false

            if let error = error as? ErrorResponse {

                if error.statusCode.orZero() == 401 {
                    self?.error = error.message.orEmpty()
                    self?.isRefreshFailed.toggle()
                } else {
                    self?.error = error.message.orEmpty()
                    self?.isError = true
                }
            } else {
                self?.isError = true
                self?.error = error.localizedDescription
            }

        }
    }

	func getTransactionDetail() async {
		onStartRequest()
        
        let result = await getTransactionDetailUseCase.execute(with: withdrawID)
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.withdrawData = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
	}
}
