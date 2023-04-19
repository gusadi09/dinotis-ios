//
//  File 2.swift
//  
//
//  Created by Gus Adi on 27/03/23.
//

import Foundation

public protocol WithdrawalBalanceUseCase {
    func execute(with request: WithdrawalRequest) async -> Result<WithdrawDetailResponse, Error>
}
