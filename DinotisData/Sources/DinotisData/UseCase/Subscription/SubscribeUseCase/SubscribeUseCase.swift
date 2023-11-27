//
//  File.swift
//  
//
//  Created by Gus Adi on 26/11/23.
//

import Foundation

public protocol SubscribeUseCase {
    func execute(for userId: String, with methodId: Int) async -> Result<SubscriptionResponse, Error>
}
