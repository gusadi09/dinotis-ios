//
//  TalentWithdrawalViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 08/11/22.
//

import Combine
import DinotisDesignSystem
import Foundation
import OneSignal
import SwiftUI
import DinotisData

final class TalentWithdrawalViewModel: ObservableObject {
	private let currentBalanceUseCase: CurrentBalanceUseCase
	private let authRepository: AuthenticationRepository
	private let getBankAccountUseCase: GetBankAccountUseCase
    private let withdrawalUseCase: WithdrawalBalanceUseCase
	private var cancellables = Set<AnyCancellable>()
	private lazy var stateObservable = StateObservable.shared
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?

	var backToRoot: () -> Void
	var backToHome: () -> Void

	@Published var colorTab = Color.clear
	@Published var contentOffset: CGFloat = 0

	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?

	@Published var isRefreshFailed = false

	@Published var bankData = [BankAccountData]()
	@Published var currentBalances = "0"

    @Published var amountError: String?

	@Published var isPresent = false

	@Published var inputAmount: Double?

	@Published var adminFee = 5500

	@Published var total = 0

	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
        authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        currentBalanceUseCase: CurrentBalanceUseCase = CurrentBalanceDefaultUseCase(),
        getBankAccountUseCase: GetBankAccountUseCase = GetBankAccountDefaultUseCase(),
        withdrawalUseCase: WithdrawalBalanceUseCase = WithdrawalBalanceDefaultUseCase()
	) {
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.authRepository = authRepository
		self.currentBalanceUseCase = currentBalanceUseCase
		self.getBankAccountUseCase = getBankAccountUseCase
        self.withdrawalUseCase = withdrawalUseCase
	}

	func balanceInputErrorChecker(amount: Double) {
		if amount < 50000.0 {
            amountError = LocalizableText.withdrawErrorLess
		} else if amount > 50000000.0 {
            amountError = LocalizableText.withdrawErrorAmountOver
		} else if amount > Double(Int(currentBalances) ?? 0) {
            amountError = LocalizableText.withdrawErrorOverBalance
		} else {
            amountError = ""
		}
	}

	func routeToRoot() {
		stateObservable.userType = 0
		stateObservable.isVerified = ""
		stateObservable.refreshToken = ""
		stateObservable.accessToken = ""
		stateObservable.isAnnounceShow = false
		OneSignal.setExternalUserId("")
		backToRoot()
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
			self?.success = false
			self?.isRefreshFailed = false
		}

	}

	func getBankAccount() async {
		onStartRequest()
        
        let result = await getBankAccountUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.bankData = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
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

	func loadCurrentUserBalance() async {
		onStartRequest()
        
        let result = await currentBalanceUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.currentBalances = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
	}

	func isEnableWithdraw() -> Bool {
		inputAmount ?? 0 < 50000.0 || inputAmount ?? 0 > 50000000.0 || inputAmount ?? 0 > Double(Int(currentBalances) ?? 0)
	}

	func onAppear() {
        Task {
            await loadCurrentUserBalance()
            await getBankAccount()
        }
	}

	func withdraw() async {
		
		onStartRequest()

		let body = WithdrawalRequest(amount: Int(inputAmount.orZero()), bankId: (bankData.first?.id).orZero(), accountName: (bankData.first?.accountName).orEmpty(), accountNumber: (bankData.first?.accountNumber).orEmpty())
        
        let result = await withdrawalUseCase.execute(with: body)
        
        switch result {
        case .success(_):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.success = true
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
	}
}
