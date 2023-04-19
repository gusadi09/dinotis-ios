//
//  File 2.swift
//  
//
//  Created by Gus Adi on 27/03/23.
//

import Foundation

public protocol WithdrawalTransactionDetailUseCase {
    func execute(with id: String) async -> Result<WithdrawDetailResponse, Error>
}
