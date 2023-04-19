//
//  BankRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/11/22.
//

import Foundation
import Combine

public protocol BankRepository {
	func provideGetBankAccount() async throws -> BankAccResponse
	func provideAddBankAccount(with body: AddBankAccountRequest) async throws -> BankAccountData
	func provideEditBankAccount(by id: Int, contain body: AddBankAccountRequest) async throws -> BankAccountData
	func provideGetBankAccountDetail(by id: Int) async throws -> BankAccountData
	func provideWithdrawBalance(by body: WithdrawalRequest) async throws -> WithdrawDetailResponse
	func provideGetWithdrawTransactionDetail(with id: String) async throws -> WithdrawDetailResponse
	func provideGetTransactionHistory() async throws -> HistoryTransactionResponse
	func provideGetListOfAvailableBank() async throws -> BankResponse
}
