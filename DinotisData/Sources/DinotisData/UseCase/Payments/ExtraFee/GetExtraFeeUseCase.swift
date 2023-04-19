//
//  File.swift
//  
//
//  Created by Garry on 02/02/23.
//

import Foundation

public protocol GetExtraFeeUseCase {
    func execute(by body: PaymentExtraFeeRequest) async -> Result<Int, Error>
}
