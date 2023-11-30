//
//  GetSubscriptionsUseCase.swift
//
//
//  Created by Irham Naufal on 30/11/23.
//

import Foundation

public protocol GetSubscriptionsUseCase {
    func execute(param: GeneralParameterRequest) async -> Result<SubscriptionListResponse, Error>
}
