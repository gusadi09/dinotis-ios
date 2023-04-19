//
//  NotificationDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/12/22.
//

import Foundation
import Moya

public final class NotificationDefaultRemoteDataSource: NotificationListRemoteDataSource {

	private let provider: MoyaProvider<NotificationListTargetType>

    public init(provider: MoyaProvider<NotificationListTargetType> = .defaultProvider()) {
		self.provider = provider
	}

    public func getNotifications(with query: NotificationRequest) async throws -> NotificationResponse {
		try await self.provider.request(.getNotification(query), model: NotificationResponse.self)
	}
    
    public func readAllNotification() async throws -> SuccessResponse {
        try await self.provider.request(.readAll, model: SuccessResponse.self)
    }
    
    public func readById(by id: String) async throws -> SuccessResponse {
        try await self.provider.request(.readById(id), model: SuccessResponse.self)
    }
}
