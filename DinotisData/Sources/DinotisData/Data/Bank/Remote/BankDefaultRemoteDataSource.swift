//
//  BankDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/11/22.
//

import Foundation
import Moya
import Combine

public final class BankDefaultRemoteDataSource: BankRemoteDataSource {

	private let provider: MoyaProvider<BankTargetType>

    public init(provider: MoyaProvider<BankTargetType> = .defaultProvider()) {
		self.provider = provider
	}

    public func getBankAccount() async throws -> BankAccResponse {
		try await self.provider.request(.getBankAccount, model: BankAccResponse.self)
	}

    public func addBankAccount(with body: AddBankAccountRequest) async throws -> BankAccountData {
        try await self.provider.request(.addBankAccount(body), model: BankAccountData.self)
	}

    public func editBankAccount(by id: Int, contain body: AddBankAccountRequest) async throws -> BankAccountData {
        try await self.provider.request(.editBankAccount(id, body), model: BankAccountData.self)
	}

    public func getBankAccountDetail(by id: Int) async throws -> BankAccountData {
        try await self.provider.request(.getBankAccountDetail(id), model: BankAccountData.self)
	}

    public func withdrawBalance(by body: WithdrawalRequest) async throws -> WithdrawDetailResponse {
        try await self.provider.request(.withdrawBalance(body), model: WithdrawDetailResponse.self)
	}

    public func getWithdrawTransactionDetail(with id: String) async throws -> WithdrawDetailResponse {
        try await self.provider.request(.withdrawTranscationDetail(id), model: WithdrawDetailResponse.self)
	}

    public func getTransactionHistory() async throws -> HistoryTransactionResponse {
        try await self.provider.request(.getTransactionHistory, model: HistoryTransactionResponse.self)
	}

    public func getListOfAvailableBank() async throws -> BankResponse {
        try await self.provider.request(.getWithdrawBankList, model: BankResponse.self)
	}
}
