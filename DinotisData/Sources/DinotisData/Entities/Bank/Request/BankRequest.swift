//
//  File.swift
//  
//
//  Created by Gus Adi on 27/03/23.
//

import Foundation

public struct AddBankAccountRequest: Codable {
    public var bankId: Int
    public var accountName: String
    public var accountNumber: String
    
    public init(bankId: Int, accountName: String, accountNumber: String) {
        self.bankId = bankId
        self.accountName = accountName
        self.accountNumber = accountNumber
    }
}

public struct WithdrawalRequest: Codable {
    public var amount: Int
    public var bankId: Int
    public var accountName: String
    public var accountNumber: String
    
    public init(amount: Int, bankId: Int, accountName: String, accountNumber: String) {
        self.amount = amount
        self.bankId = bankId
        self.accountName = accountName
        self.accountNumber = accountNumber
    }
}
