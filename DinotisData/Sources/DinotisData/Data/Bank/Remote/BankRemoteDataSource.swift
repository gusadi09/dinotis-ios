//
//  BankRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/11/22.
//

import Foundation
import Combine

public protocol BankRemoteDataSource {
	func getBankAccount() async throws -> BankAccResponse
	func addBankAccount(with body: AddBankAccountRequest) async throws -> BankAccountData
	func editBankAccount(by id: Int, contain body: AddBankAccountRequest) async throws -> BankAccountData
	func getBankAccountDetail(by id: Int) async throws -> BankAccountData
	func withdrawBalance(by body: WithdrawalRequest) async throws -> WithdrawDetailResponse
	func getWithdrawTransactionDetail(with id: String) async throws -> WithdrawDetailResponse
	func getTransactionHistory() async throws -> HistoryTransactionResponse
	func getListOfAvailableBank() async throws -> BankResponse
}
