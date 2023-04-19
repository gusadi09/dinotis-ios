//
//  File.swift
//  
//
//  Created by Gus Adi on 27/03/23.
//

import Foundation

public struct BankAccountData: Codable {
    public let id: Int?
    public let accountName: String?
    public let accountNumber: String?
    public let bankId: Int?
    public let userId: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let bank: BankData?
}

public typealias BankAccResponse = [BankAccountData]

public struct BankData: Codable {
    public let id: Int?
    public let name: String?
    public let iconUrl: String?
    public let xenditCode: String?
    public let createdAt: Date?
    public let updatedAt: Date?
}

public typealias BankResponse = [BankData]

public struct WithdrawDetailResponse: Codable {
    public let id: String?
    public let amount: Int?
    public let isFailed: Bool?
    public let doneAt: Date?
    public let bankAccountId: Int?
    public let balanceDetailId: Int?
    public let externalId: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let bankAccount: BankAccountData?
}

public struct HistoryTransactionResponse: Codable {
    public let id: Int?
    public let current: String?
    public let userId: String?
    public let updatedAt: Date?
    public let balanceDetails: [BalanceDetailData]?
}

public struct BalanceDetailData: Codable {
    public let id: Int?
    public let amount: Int?
    public let isOut: Bool?
    public let balanceId: Int?
    public let transactionId: String?
    public let isConfirmed: Bool?
    public let createdAt: Date?
    public let topUp: String?
    public let balance: UserDetailBalance?
    public let transaction: String?
    public let withdraw: UserWithdrawHistory?
}

public struct UserDetailBalance: Codable {
    public let id: Int?
    public let current: String?
    public let userId: String?
    public let updatedAt: Date?
}

public struct UserWithdrawHistory: Codable {
    public let id: String?
    public let amount: Int?
    public let isFailed: Bool?
    public let doneAt: String?
    public let bankAccountId: Int?
    public let balanceDetailId: Int?
    public let externalId: String?
    public let createdAt: Date?
    public let updatedAt: Date?
}
