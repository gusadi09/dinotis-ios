//
//  File 2.swift
//  
//
//  Created by Gus Adi on 27/03/23.
//

import Foundation

public protocol AddBankAccountUseCase {
    func execute(by query: AddBankAccountRequest) async -> Result<BankAccountData, Error>
}
