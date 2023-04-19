//
//  File 2.swift
//  
//
//  Created by Gus Adi on 27/03/23.
//

import Foundation

public protocol GetWithdrawBankListUseCase {
    func execute() async -> Result<BankResponse, Error>
}
