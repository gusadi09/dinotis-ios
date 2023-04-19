//
//  File 2.swift
//  
//
//  Created by Gus Adi on 27/03/23.
//

import Foundation

public protocol EditBankAccountUseCase {
    func execute(for id: Int, with query: AddBankAccountRequest) async -> Result<BankAccountData, Error>
}
