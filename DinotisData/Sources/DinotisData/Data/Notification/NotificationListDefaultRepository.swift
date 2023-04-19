//
//  NotificationListDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/12/22.
//

import Foundation
import Combine

public final class NotificationListDefaultRepository: NotificationListRepository {

	private let remote: NotificationListRemoteDataSource

    public init(remote: NotificationListRemoteDataSource = NotificationDefaultRemoteDataSource()) {
		self.remote = remote
	}

    public func provideGetNotifications(with query: NotificationRequest) async throws -> NotificationResponse {
		try await self.remote.getNotifications(with: query)
	}
    
    public func provideReadAllNotification() async throws -> SuccessResponse {
        try await self.remote.readAllNotification()
    }
    
    public func provideReadById(by id: String) async throws -> SuccessResponse {
        try await self.remote.readById(by: id)
    }
}
