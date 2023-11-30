//
//  File.swift
//  
//
//  Created by Gus Adi on 26/11/23.
//

import Foundation

public protocol SubscriptionRepository {
    func providePostSubscribe(userId: String, methodId: Int) async throws -> SubscriptionResponse
    func providePostUnsubscribe(with userId: String) async throws -> SuccessResponse
}
