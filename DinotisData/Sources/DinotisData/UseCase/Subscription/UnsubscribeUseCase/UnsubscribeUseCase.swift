//
//  UnsubscribeUseCase.swift
//
//
//  Created by Irham Naufal on 29/11/23.
//

import Foundation

public protocol UnsubscribeUseCase {
    func execute(with userId: String) async -> Result<SuccessResponse, Error>
}
