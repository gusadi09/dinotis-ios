//
//  TalentAddBankAccountViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/11/22.
//

import Foundation
import OneSignal
import Combine
import DinotisData
import DinotisDesignSystem

final class TalentAddBankAccountViewModel: ObservableObject {
	private let userRepository: UsersRepository
	private let authRepository: AuthenticationRepository
	private let getBankAccountUseCae: GetBankAccountUseCase
    private let getBankListUseCase: GetWithdrawBankListDefaultUseCase
    private let addBankAccountUseCase: AddBankAccountUseCase
    private let editBankAccountUseCase: EditBankAccountUseCase
	private var cancellables = Set<AnyCancellable>()
	private lazy var stateObservable = StateObservable.shared

	private let isEdit: Bool

	var backToRoot: () -> Void
	var backToHome: () -> Void

	@Published var accountNumber = ""
	@Published var accountName = ""

	@Published var isPresentBank = false

	@Published var selectionBank: BankData?

	@Published var searchBank = ""

	@Published var isLoading = false
	@Published var isError = false
	@Published var success = false
	@Published var error: String?

	@Published var isRefreshFailed = false

	@Published var bankData = [BankAccountData]()

	@Published var bankList = [BankData]()
    
    @Published var alert = AlertAttribute()

	init(
		isEdit: Bool,
		backToRoot: @escaping (() -> Void),
		backToHome: @escaping (() -> Void),
		userRepository: UsersRepository = UsersDefaultRepository(),
		authRepository: AuthenticationRepository = AuthenticationDefaultRepository(),
        getBankAccountUseCae: GetBankAccountUseCase = GetBankAccountDefaultUseCase(),
        getBankListUseCase: GetWithdrawBankListDefaultUseCase = GetWithdrawBankListDefaultUseCase(),
        addBankAccountUseCase: AddBankAccountUseCase = AddBankAccountDefaultUseCase(),
        editBankAccountUseCase: EditBankAccountUseCase = EditBankAccountDefaultUseCase()
	) {
		self.isEdit = isEdit
		self.backToRoot = backToRoot
		self.backToHome = backToHome
		self.userRepository = userRepository
		self.authRepository = authRepository
		self.getBankAccountUseCae = getBankAccountUseCae
        self.getBankListUseCase = getBankListUseCase
        self.addBankAccountUseCase = addBankAccountUseCase
        self.editBankAccountUseCase = editBankAccountUseCase
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

	func onStartRequest() {
		DispatchQueue.main.async {[weak self] in
			self?.isLoading = true
			self?.isError = false
			self?.error = nil
			self?.success = false
			self?.isRefreshFailed = false
		}

	}

	func headerTitle() -> String {
		isEdit ? LocaleText.editBankAccountTitle : LocaleText.addWithdrawalAccountTitle
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

	func getBankAccount() async {
		onStartRequest()
        
        let result = await getBankAccountUseCae.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                
                self?.bankData = success

                if let account = success.first {
                    self?.accountName = account.accountName.orEmpty()
                    self?.accountNumber = account.accountNumber.orEmpty()
                    self?.selectionBank = account.bank
                }
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
	}

	func getBankList() async {
		onStartRequest()
        
        let result = await getBankListUseCase.execute()
        
        switch result {
        case .success(let success):
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                self?.bankList = success
            }
        case .failure(let failure):
            handleDefaultError(error: failure)
        }
	}

	func addBankAccount() async {
		onStartRequest()

		let body = AddBankAccountRequest(bankId: (selectionBank?.id).orZero(), accountName: accountName, accountNumber: accountNumber)
        
        let result = await addBankAccountUseCase.execute(by: body)
        
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

	func editBankAccount() async {
		onStartRequest()

		let body = AddBankAccountRequest(bankId: (selectionBank?.id).orZero(), accountName: accountName, accountNumber: accountNumber)
        
        let result = await editBankAccountUseCase.execute(for: (bankData.first?.id).orZero(), with: body)
        
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

	func onAppear() {
        Task {
            await self.getBankAccount()
            await self.getBankList()
        }
	}
}
