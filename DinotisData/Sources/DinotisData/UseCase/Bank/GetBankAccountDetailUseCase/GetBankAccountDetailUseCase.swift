//
//  File.swift
//  
//
//  Created by Gus Adi on 28/03/23.
//

import Foundation

public protocol GetBankAccountDetailUseCase {
    func execute(for id: Int) async -> Result<BankAccountData, Error>
}
