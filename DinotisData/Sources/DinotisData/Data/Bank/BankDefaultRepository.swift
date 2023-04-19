//
//  BankDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/11/22.
//

import Foundation
import Combine

public final class BankDefaultRepository: BankRepository {

	private let remote: BankRemoteDataSource

    public init(remote: BankRemoteDataSource = BankDefaultRemoteDataSource()) {
		self.remote = remote
	}

    public func provideGetBankAccount() async throws -> BankAccResponse {
		try await self.remote.getBankAccount()
	}

    public func provideAddBankAccount(with body: AddBankAccountRequest) async throws -> BankAccountData {
        try await self.remote.addBankAccount(with: body)
	}

    public func provideEditBankAccount(by id: Int, contain body: AddBankAccountRequest) async throws -> BankAccountData {
        try await self.remote.editBankAccount(by: id, contain: body)
	}

    public func provideGetBankAccountDetail(by id: Int) async throws -> BankAccountData {
        try await self.remote.getBankAccountDetail(by: id)
	}

    public func provideWithdrawBalance(by body: WithdrawalRequest) async throws -> WithdrawDetailResponse {
        try await self.remote.withdrawBalance(by: body)
	}

    public func provideGetWithdrawTransactionDetail(with id: String) async throws -> WithdrawDetailResponse {
        try await self.remote.getWithdrawTransactionDetail(with: id)
	}

    public func provideGetTransactionHistory() async throws -> HistoryTransactionResponse {
        try await self.remote.getTransactionHistory()
	}

    public func provideGetListOfAvailableBank() async throws -> BankResponse {
        try await self.remote.getListOfAvailableBank()
	}
}
