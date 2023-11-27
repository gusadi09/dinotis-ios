//
//  File.swift
//  
//
//  Created by Gus Adi on 26/11/23.
//

import Foundation

public protocol SubscriptionRemoteDataSource {
    func postSubscribe(userId: String, methodId: Int) async throws -> SubscriptionResponse
}
