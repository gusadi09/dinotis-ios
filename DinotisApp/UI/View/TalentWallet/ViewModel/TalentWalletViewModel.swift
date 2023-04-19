//
//  TalentWalletViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 26/02/22.
//

import Combine
import Foundation
import OneSignal
import SwiftUI
import DinotisData
import DinotisDesignSystem

final class TalentWalletViewModel: ObservableObject {

	private let currentBalanceUseCase: CurrentBalanceUseCase
	private let authRepository: AuthenticationRepository
	private let getHistoryTransactionUseCase: GetTransactionHistoryUseCase
    private let getBankAccountUseCase: GetBankAccountUseCase
	private var cancellables = Set<AnyCancellable>()
	private lazy var stateObservable = StateObservable.shared
	private var onValueChanged: ((_ refreshControl: UIRefreshControl) -> Void)?
	
	var backToRoot: () -> Void
	var backToHome: () -> Void

    @Published var alert = AlertAttribute()
	@Published var selectedTab = 0

	@Published var isGoToPendapatan = false

	@Published var selectionHistory: BalanceDetails?
	@Published var currentBalances = "0"
	@Published var bankData = [BankAccountData]()
	@Published var dataHistory: HistoryTransactionResponse?
	@Published var balanceDetailData = [BalanceDetailData]()

	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?

	@Published var route: HomeRouting?
	@Published var isRefreshFailed = false
	
	init(
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		currentBalanceUseCase: CurrentBalanceUseCase = CurrentBalanceDefaultUseCase(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        getHistoryTransactionUseCase: GetTransactionHistoryUseCase = GetTransactionHistoryDefaultUseCase(),
        getBankAccountUseCase: GetBankAccountUseCase = GetBankAccountDefaultUseCase()
	) {
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.currentBalanceUseCase = currentBalanceUseCase
		self.authRepository = authRepository
		self.getHistoryTransactionUseCase = getHistoryTransactionUseCase
        self.getBankAccountUseCase = getBankAccountUseCase
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
    
    func balanceDetailFilter() -> [BalanceDetailData] {
        return balanceDetailData.filter({ value in
            if selectedTab == 0 {
                return true
            } else if selectedTab == 1 {
                return !(value.isOut ?? false)
            } else {
                return value.isOut ?? false
            }
        })
    }

	func addBankAccountIcon() -> Image {
		bankData.isEmpty ? Image.Dinotis.plusIcon : Image.Dinotis.pencilIcon
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
    
    func getHistoryTransaction() async {
        onStartRequest()
        
        let result = await getHistoryTransactionUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.dataHistory = success
                self?.balanceDetailData = success.balanceDetails ?? []
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
	}

	func onAppear() {
        Task {
            await self.loadCurrentUserBalance()
            await self.getBankAccount()
            await self.getHistoryTransaction()
        }
	}

	func routeToAddBankAccount() {
		let viewModel = TalentAddBankAccountViewModel(isEdit: bankData.first != nil, backToRoot: self.backToRoot, backToHome: self.backToHome)

		DispatchQueue.main.async { [weak self] in
			self?.route = .addBankAccount(viewModel: viewModel)
		}
	}

	func routeToWithdrawDetail(id: String) {
		let viewModel = TalentTransactionDetailViewModel(withdrawID: id, backToRoot: self.backToRoot, backToHome: self.backToHome)

		DispatchQueue.main.async { [weak self] in
			self?.route = .withdrawTransactionDetail(viewModel: viewModel)
		}
	}

	func routeToWithdrawal() {
		let viewModel = TalentWithdrawalViewModel(backToRoot: self.backToRoot, backToHome: self.backToHome)

		DispatchQueue.main.async { [weak self] in
			self?.route = .withdrawBalance(viewModel: viewModel)
		}
	}
}
