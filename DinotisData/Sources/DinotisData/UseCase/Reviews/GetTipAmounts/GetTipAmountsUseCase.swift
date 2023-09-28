//
//  File.swift
//  
//
//  Created by Irham Naufal on 14/09/23.
//

import Foundation

public protocol GetTipAmountsUseCase {
    func execute() async -> Result<TipAmounts, Error>
}
